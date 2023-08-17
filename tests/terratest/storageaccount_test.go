package test

import (
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// Testing the secure-file-transfer Module
func TestTerraformAzureStorageAccount(t *testing.T) {
	t.Parallel()

	//subscriptionID := "e6b5053b-4c38-4475-a835-a025aeb3d8c7"
	// Terraform plan.out File Path
	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "example/")
	planFilePath := filepath.Join(exampleFolder, "plan.out")

	terraformPlanOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../example/",
		Upgrade:      true,

		// Variables to pass to our Terraform code using -var options
		VarFiles: []string{"for_terratest.tfvars"},

		//Environment variables to set when running Terraform

		// Configure a plan file path so we can introspect the plan and make assertions about it.
		PlanFilePath: planFilePath,
	})

	// Run terraform init plan and show and fail the test if there are any errors
	terraform.InitAndPlanAndShowWithStruct(t, terraformPlanOptions)

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformPlanOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformPlanOptions)

	// Run `terraform output` to get the values of output variables
	resourceGroupName := terraform.Output(t, terraformPlanOptions, "resource_group_name")
	storageAccountName := terraform.Output(t, terraformPlanOptions, "storage_account_name")
	storageAccountId := terraform.Output(t, terraformPlanOptions, "storage_account_id")
	subscriptionID := terraform.Output(t, terraformPlanOptions, "subscription_id")

	// Assert statements - check if storage account exists
	assert.True(t, azure.StorageAccountExists(t, storageAccountName, resourceGroupName, subscriptionID))
	storageAccount, _ := azure.GetStorageAccountE(storageAccountName, resourceGroupName, subscriptionID)
	storageAccountKind, _ := azure.GetStorageAccountKindE(storageAccountName, resourceGroupName, subscriptionID)
	storageAccountProperties, _ := azure.GetStorageAccountPropertyE(storageAccountName, resourceGroupName, subscriptionID)

	assert.Equal(t, storageAccountId, *storageAccount.ID)
	assert.Equal(t, "StorageV2", storageAccountKind)
	assert.Equal(t, "Standard_LRS", string(storageAccount.Sku.Name))
	assert.Equal(t, "Deny", string(storageAccountProperties.NetworkRuleSet.DefaultAction))
	assert.Equal(t, "TLS1_2", string(storageAccountProperties.MinimumTLSVersion))
}
