import groovy.json.JsonSlurper

/**
 * SRAlignWorkflow class is a class to perform necessary workflow functions upon initialization.
 * These functions include: creating a header for STDOUT and documentation, generating help documentation, checking that specified params are valid, and others.
*/
class SRAlignWorkflow {
    /*
    ---------------------------------------------------------------------
        Fields and properties
    ---------------------------------------------------------------------
    */

    // workflow features
    /** built-in Nextflow logging */
    public static def           log
    /** Parameters specified in the workflow */
    public static def           params
    /** workflow introspection */
    public static def           workflow
    /** Specifications for parameters such as default values, param descriptions, etc. to be used in creating help documentation and check parameters. */
    public static LinkedHashMap paramSpecs
    /** Output basename prefix */
    public static String        outBasePrefix
    /** Output basename unique prefix */
    public static String        outUniquePrefix

    /** valid tools available in the pipeline */
    public static LinkedHashMap validTools = [
        trim      : ['fastp'],
        alignment : ['bowtie2', 'hisat2']
    ]

    // pipeline ASCII logo
    public static final String pipelineLogo = (
        """
         ######  ########     ###    ########    ###     ######  
        ##    ## ##     ##   ## ##      ##      ## ##   ##    ## 
        ##       ##     ##  ##   ##     ##     ##   ##  ##       
         ######  ########  ##     ##    ##    ##     ## ##       
              ## ##   ##   #########    ##    ######### ##       
        ##    ## ##    ##  ##     ##    ##    ##     ## ##    ## 
         ######  ##     ## ##     ##    ##    ##     ##  ######  

        """
    )

    // pipeline name
    public static final String pipelineName = "trev-f/SRAtac"

    // purpose statement
    public static final String purpose = (
        """
        A pipeline for ATAC-seq data analysis built on SRAlign.
        """
    )

    // general nextflow help
    public static final String generalNFHelp = (
        """
        Nextflow command-line options:
            nextflow help

        Nextflow run command-line options:
            nextflow run -help
        """
    )

    // usage statement
    public static final String usage = (
        """
        nextflow run trev-f/SRAtac -profile docker --input <input.csv> --genome <valid genome key>
        """
    )

    /*
    ---------------------------------------------------------------------
        Methods
    ---------------------------------------------------------------------
    */
        
    /**
     * SRAlignWorkflow constructor method
     *
     * @param log the Nextflow log object
     * @param params the workflow parameters
     * @param paramSpecs the parameters specifications and defaults
     *
     * @return SRAlignWorkflow object
    */
    SRAlignWorkflow(log, params, workflow) {
        // set log
        this.log             = log
        this.params          = params
        this.workflow        = workflow
        this.paramSpecs      = (new JsonSlurper()).parse(new File("${workflow.projectDir}/parameter_specifications.json"))
        this.outBasePrefix   = params.input ? params.input.take(params.input.lastIndexOf('.')).split('/')[-1] : ''
        this.outUniquePrefix = params.input ? constructOutBasePrefix(params, workflow) : ''

        // add options to paramSpecs
        LinkedHashMap paramSpecs = addValidOptions(params, paramSpecs)

        // display the header
        log.info createHeader()

        // display a help message and exit the program
        if (params.help) {
            log.info getHelp(paramSpecs)
            System.exit(0)
        }

        // check that only valid tools are specified
        checkTools(validTools, params)

        // check that input and MultiQC config are specified and exist
        checkInputs(params)

        // check reference and contaminant genomes
        checkReferences(params)
    }


    /**
     * Creates a header from pipeline info to be displayed on STDOUT and in logging.
     *
     * @return a header message
    */
    public static String createHeader() {
        // initialize an empty header list
        def header = []

        // add pipeline header info to list
        header.add(pipelineLogo)
        header.add(pipelineName)
        header.add(purpose)
        header.add("")              // extra newline at end helps formatting look better

        // return header info as string with new line breaks
        header.join("\n")
    }


    /**
     * Creates a method for adding options to paramSpecs
     *
     * @param paramSpecs parameter specifications
     *
     * @return parameter specifications with valid options added
    */
    public static LinkedHashMap addValidOptions(params, paramSpecs) {
        // add valid genome options to genome and contaminant
        paramSpecs.mandatory.parameters.genome.options       = params.genomes.keySet()
        paramSpecs.references.parameters.contaminant.options = params.genomes.keySet()

        // add valid tools
        paramSpecs.trimReads.parameters.trimTool.options      = validTools.trim
        paramSpecs.alignment.parameters.alignmentTool.options = validTools.alignment

        return paramSpecs
    }


    /**
     * Writes a string of help documentation from parameter specifications
     *
     * @param paramSpecs the parameters specifications and defaults
     *
     * @return a mature help message string for parameters
    */
    public static String writeParamHelpDoc(LinkedHashMap specs) {
        // initialize an emtpy list of help doc strings
        List helpDoc = []
        
        // iterate through parameter specifications
        specs.each {
            // break into categories
            category ->
            
            // add category title as help doc subsection title
            helpDoc.add("${category.value.title}:")
            
            // iterate through parameter specifications within the category
            category.value.parameters.each{
                spec ->
                
                // add parameter name to help doc
                helpDoc.add("${"".padRight(8)}--${spec.key}")
                
                // add parameter description to help doc
                helpDoc.add("${"".padRight(16)}${spec.value.description}")
                
                // add parameter default value to help doc
                if (spec.value.default) {
                    helpDoc.add("${"".padRight(16)}Default: ${spec.value.default}")
                }
                
                // add paramater value options to doc
                if (spec.value.options) {
                    helpDoc.add("${"".padRight(16)}Options: ${spec.value.options}")
                }
                            
                // extra newline at end helps formatting look better
                helpDoc.add("")
            }
            // extra newline at end helps formatting look better
            helpDoc.add("")
        }
        // create help string
        helpDoc.join("\n")
    }


    /**
     * Creates a help message for parameter specifications
     *
     * @param paramSpecs the parameters specifications and defaults
     *
     * @return help documentation
    */
    public static String getHelp(paramSpecs) {
        // initialize an empty help list
        def help = []

        // add help message info to list
        help.add("Nextflow command-line help:${generalNFHelp}")
        help.add("")                // extra newline helps formatting look better
        help.add("Usage:${usage}")
        help.add("")

        // add param help messages
        help.add(writeParamHelpDoc(paramSpecs))
        help.add("")

        // return help message as string with new line breaks
        help.join("\n")
    }


    /**
     * Checks that valid tools are specified for each process where choosing a tool is an option.
     * Returns nothing if valid tools are specified, otherwise returns an assertion error.
     *
     * @param validTools a map of valid tool choices. Keys are the function of each tool (e.g. trim and alignment). Values are a list of available tools for that function.
     * @param params parameters
    */
    public static def checkTools(validTools, params) {
        // check valid read-trimming tool
        assert params.trimTool in validTools.trim, 
            "'${params.trimTool}' is not a valid read-trimming tool option.\n\tValid read-trimming tool options: ${validTools.trim.join(', ')}\n\t" 
        
        // check valid alignment tool
        assert params.alignmentTool in validTools.alignment , 
            "'${params.alignmentTool}' is not a valid alignment tool option.\n\tValid alignment tool options: ${validTools.alignment.join(', ')}\n\t"
    }


    /**
     * Checks that inputs and MultiQC config exist
     *
     * @param params parameters
    */
    public static def checkInputs(params) {
        // check that input design is specified and exists
        assert params.input ,                       // check input is specified
            "Input design file not specified. An input design file is required.\n"

        assert new File(params.input).exists() || new URL(params.input).openConnection().getResponseCode() == 200 ,    // check input file exists or that connecting to the URL succeeds
            "'${params.input}' does not exist. An existing input design file is required.\n"

        // check that MultiQC config exists
        assert params.multiqcConfig ,                       // check MultiQC config is specified
            "MultiQC config file not specified. A MultiQC config file is required.\n"

        assert new File(params.multiqcConfig).exists() ,    // check MultiQc file exists
            "'${params.multiqcConfig}' does not exist. An existing MultiQC config file is required.\n"
    }


    /**
     * Checks reference genome and contaminant
     *
     * @param params parameters
    */
    public static def checkReferences(params) {
        // check reference genome
        if (!params.skipAlignGenome) {
            assert params.genomes && params.genome && params.genomes.containsKey(params.genome) ,
                "Reference genome '${params.genome}' is not a valid genome option.\n\tValid genome options: ${params.genomes.keySet().join(", ")}\n\t"
        }

        // check contaminant genome
        if (!params.skipAlignContam) {
            assert params.genomes && params.contaminant && params.genomes.containsKey(params.contaminant) ,
                "Contaminant genome '${params.contaminant}' is not a valid genome option.\n\tValid genome options: ${params.genomes.keySet().join(", ")}\n\t"
        }
    }


    /**
     * Constructs an ouput basename prefix
     *
     * @param params parameters
     *
     * @return output basename prefix string
    */
    public static String constructOutBasePrefix(params, workflow) {
        // set input design name
        String inBaseName = params.input.take(params.input.lastIndexOf('.')).split('/')[-1]

        // set a timestamp
        def timeStamp = new java.util.Date().format('yyyy-MM-dd_HH-mm')

        // set output basename prefix
        "${inBaseName}_-_${workflow.runName}_-_${timeStamp}"
    }
}
