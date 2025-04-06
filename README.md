# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)



# Salesforce lookup rollup (Apex code based)

The lookup package contains an Apex-based rollup solution on objects with lookup relationship. It provides the following rollup operations;
- SUM: summary;
- COUNT: counting the number of child records;
- AVG: calculate the average on a field on the child records;
- MIN and MAX: minimum and maximum values of a filed on the related child records.

Definitions of the rollup logic are stored in the RollupOperation__c custom object. The original rollup definitions can be uploaded to the object from the RollupOperationTestData.json file which is stored as a static resource.
The upload to the RollupOperation__c custom object can be done by the
- DemoDataCreation.createRollupOperations() method.

# Deployment to a scratch org

The package can be deployed by the standard sf CLI commands to a scratch org. The scratch definition file can be found at /config/project-scratch-def.json.

After cloning the repository, define the scratch org named as "lookup_rollup" as described here: 

- sf org create scratch --target-dev-hub MyHub --alias lookup_rollup --definition-file config/project-scratch-def.json --set-default --duration-days 3

The following command wish push the metadata to the newly created scratch org:
- sf project deploy start —source-dir path/to/source —target-org basic_package
(where "path/to/source" denotes the source metadata).

# Usage

## Create Demo Data

The package contains Account rollup fields from the related Contact object:
- NumberOfContacts__c: stores the actual number of the related Contacts ("COUNT");

The complete setup on the demo accounts can be achieved by invoking the the following two Apex methods, in the described order:
- DemoDataCreation.createRollupOperations() ;
- DemoDataCreation.createAll() command from VSC or from the Anonymous Window in the Developer Console.

