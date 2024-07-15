#!/bin/bash

# このスクリプトは、Azure CLIを使用してAzure Active Directory (Azure AD) アプリケーションとサービス プリンシパルを作成し、 
# そのアプリケーションに対してロールを割り当て、フェデレーテッド資格情報を作成するためのものです。

############################################################
# Definitions of common variables.

# 出力モードを設定します。
VERBOSE_MODE=false

# Azureリソースの名前を設定します。
RG_NAME=

# Entraアプリケーションの表示名を設定します。
APP_NAME=

# EntraアプリケーションのクライアントIDを設定します。
SUB_ID=

# EntraのテナントIDを設定します。
TENANT_ID=

# EntraアプリケーションのクライアントIDを設定します。
APP_CLIENT_ID=

############################################################
# Definitions of functions.

# この関数は、標準出力にメッセージを出力するためのものです。
# 引数として出力するメッセージを受け取ります。
# 引数No.1: 出力するメッセージ (必須)
# 引数No.2: 標準エラー出力に出力するかどうか (オプション) ex. "true"
stderr() {
    if [ "$2" = "true" ] || [ "$VERBOSE_MODE" = true ]; then
        echo -e "$1" 1>&2
    fi
}

# この関数は、デバッグメッセージを標準エラー出力に出力するためのものです。
# 引数として出力するデバッグメッセージを受け取ります。
# VERBOSE_MODEがtrueの場合のみ出力されます。
# 引数No.1: 出力するデバッグメッセージ (必須)
debug() {
    stderr "$1"
}

# この関数は、エラーメッセージを標準エラー出力に出力するためのものです。
# 引数として出力するエラーメッセージを受け取ります。
# VERBOSE_MODEの値に関係なく、常に出力されます。
# 引数No.1: 出力するエラーメッセージ (必須)
error() {
    stderr "$1" true
}

# この関数は、出力メッセージを標準出力に出力するためのものです。
# 引数として出力するメッセージを受け取ります。
# VERBOSE_MODEの値に関係なく、常に出力されます。
# 引数No.1: 出力するメッセージ (必須)
output() {
    stderr "$1" true
}

# この関数は、現在のサブスクリプションIDを取得するためのものです。
# 現在のサブスクリプションIDを取得し、その値を返します。
get_account() {
    local account=$(az account show)
    if [ -z "$account" ]; then
        error "Account not found."
        exit 1
    fi
    echo $account
}

# この関数は、新しいアプリケーションを作成するためのものです。
# 引数として新規に作成するアプリケーション名を受け取ります。
# 指定された名のアプリケーションが既に存在するかどうかを確認し、存在する場合は既存アプリケーションのjsonテキストを返します。
# 存在しない場合は新しいアプリケーションを作成し、作成されたアプリケーションのjsonテキストを返します。
# 引数No.1: アプリケーション名 (必須) ex. "GithubActions"
create_new_application() {
    if [ -z "$1" ]; then
        error "Application name is required."
        exit 1
    fi

    local app_display_name=$1

    # 指定の名前のアプリケーションが既に存在するか確認
    local cur_app=$(az ad app list --display-name $app_display_name -o json)
    if [ -n "$cur_app" ] && [ "$cur_app" != "[]" ]; then
        debug "Application already exists."
        echo $cur_app
        exit 1
    fi

    # 新規にアプリケーションを作成
    local new_app=$(az ad app create --display-name $app_display_name)
    echo $new_app
}

# この関数は、新しいService Principalを作成するためのものです。
# 引数として作成済みアプリケーションのClientIDを受け取ります。
# 指定されたClientIDのService Principalが既に存在するかどうかを確認し、存在する場合は既存Service Principalのjsonテキストを返します。
# 存在しない場合は新しいService Principalを作成し、作成されたService Principalのjsonテキストを返します。
# 引数No.1: アプリケーションのClientID (必須) ex. "1c8e542e-8a5b-455c-8842-db4bd266248f"
create_new_service_principal() {
    if [ -z "$1" ]; then
        error "Application ClientID is required."
        exit 1
    fi

    local app_client_id=$1

    # 指定のClientIDのService Principalが既に存在するか確認
    local cur_sp=$(az ad sp show --id $app_client_id -o json)
    if [ -n "$cur_sp" ] && [ "$cur_sp" != "[]" ]; then
        debug "Service Principal already exists."
        echo $cur_sp
        exit 1
    fi

    # new_appのService Principalを作成
    # local appClientId=$(echo $new_app | jq -r '.appId')
    local new_sp=$(az ad sp create --id $app_client_id)
    echo $new_sp
}

# この関数は、指定されたService Principalにロールを追加するためのものです。
# 引数としてSubscriptionID, ResourceGroupName, PrincipalType, ServicePrincipalID, Role, RoleScopeを受け取ります。
# 指定されたスコープリソースのロールが既に存在するかどうかを確認し、存在する場合は既存のロールのjsonテキストを返します。
# 存在しない場合は指定されたスコープリソースのロールを追加し、追加されたロールのjsonテキストを返します。
# 引数No.1: SubscriptionID (必須) ex. "00000000-0000-0000-0000-000000000000"
# 引数No.2: ResourceGroupName (必須) ex. "myResourceGroup"
# 引数No.3: PrincipalType (必須) ex. "ServicePrincipal"
# 引数No.4: ServicePrincipalID (必須) ex. "1c8e542e-8a5b-455c-8842-db4bd266248f"
# 引数No.5: RoleType (必須) ex. "Contributor"
# 引数No.6: RoleScope (必須) ex. "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup"
add_role() {
    if [ -z "$1" ]; then
        error "SubscriptionID are required."
        exit 1
    fi
    if [ -z "$2" ]; then
        error "ResourceGroupName are required."
        exit 1
    fi
    if [ -z "$3" ]; then
        error "PrincipalType are required."
        exit 1
    fi
    if [ -z "$4" ]; then
        error "ServicePrincipalID are required."
        exit 1
    fi
    if [ -z "$5" ]; then
        error "RoleType are required."
        exit 1
    fi
    if [ -z "$6" ]; then
        error "RoleScope are required."
        exit 1
    fi

    local sub_id=$1
    local rg_name=$2
    local principal_type=$3
    local sp_id=$4
    local role_type=$5
    local role_scope=$6

    # 指定されたスコープリソースのロールが既に存在するか確認
    local cur_role=$(az role assignment list --resource-group $rg_name --assignee $sp_id)
    if [ -n "$cur_role" ] && [ "$cur_role" != "[]" ]; then
        debug "Role already exists."
        echo $cur_role
        exit 1
    fi

    # 指定されたスコープリソースのロールを追加
    local new_role=$(az role assignment create --role $role_type --subscription $sub_id --assignee-object-id $sp_id --assignee-principal-type $principal_type --scope $role_scope)
    echo $new_role
}

# この関数は、指定されたアプリケーションに新しいフェデレーテッド資格情報を作成するためのものです。
# 引数としてアプリケーションのObjectIDと資格情報パラメータを受け取ります。
# 指定されたアプリケーションのフェデレーテッド資格情報が既に存在するかどうかを確認し、存在する場合は既存のフェデレーテッド資格情報のjsonテキストを返します。
# 存在しない場合は新しいフェデレーテッド資格情報を作成し、作成されたフェデレーテッド資格情報のjsonテキストを返します。
# 引数No.1: アプリケーションのObjectID (必須) ex. "1c8e542e-8a5b-455c-8842-db4bd266248f"
# 引数No.2: 資格情報パラメータ (必須) ex. "githubactions.json"
create_new_federated_credential() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        error "Application Object ID and Credential Parameter are required."
        exit 1
    fi

    local app_object_id=$1
    local credential_param=$2

    # 指定されたアプリケーションのフェデレーテッド資格情報が既に存在するか確認
    local cur_credential=$(az ad app federated-credential list --id $app_object_id)
    if [ -n "$cur_credential" ] && [ "$cur_credential" != "[]" ]; then
        debug "Federated Credential already exists."
        echo $cur_credential
        exit 1
    fi

    local new_credential=$(az ad app federated-credential create --id $app_object_id --parameters $credential_param)
    echo $new_credential
}

# この関数は、Microsoft Entra と Github actions の間で信頼関係を設定するために federated Identity Credential を作成します。
# 実行結果として、以下の情報を出力します。
# - Application (Client) ID
# - Directory (Tenant) ID
# - Subscription ID
# これらの情報は Github Actions側のシークレットに設定する必要があります。
main() {

    # 現在のアカウント情報を取得
    debug "\n--- Get Current Account ---"

    account=$(get_account)
    if [ -z "$account" ]; then
        error "Account not found. You should login first if you make this script run."
        exit 1
    fi
    debug "Account JSON : $account"
    SUB_ID=$(echo $account | jq -r '.id')
    TENANT_ID=$(echo $account | jq -r '.tenantId')

    # 新しいアプリケーションを作成
    debug "\n--- Create New Application ---"
    new_app=$(create_new_application $APP_NAME)
    debug "Application JSON : $new_app"

    # 新しいService Principalを作成
    debug "\n--- Create New Service Principal ---"
    APP_CLIENT_ID=$(echo $new_app | jq -r '.[].appId')
    new_sp=$(create_new_service_principal $APP_CLIENT_ID)
    debug "Service Principal JSON : $new_sp"

    # 指定されたService Principalにロールを追加
    debug "\n--- Add Role to Service Principal ---"
    principal_type="ServicePrincipal"
    role_type="Contributor"
    debug "role_type : $role_type"
    role_scope="/subscriptions/$SUB_ID/resourceGroups/$RG_NAME"

    sp_id=$(echo $new_sp | jq -r '.appId')
    role=$(add_role $SUB_ID $RG_NAME $principal_type $sp_id $role_type $role_scope)
    debug "Role JSON : $role"

    # 指定されたアプリケーションに新しいフェデレーテッド資格情報を作成
    debug "\n--- Create New Federated Credential ---"
    credential_param="./githubactions.json"

    app_object_id=$(echo $new_app | jq -r '.[].id')
    new_credential=$(create_new_federated_credential $app_object_id $credential_param)
    debug "Federated Credential JSON : $new_credential"

    # 出力
    output "\n--- Output ---"
    output "Tenant ID : $TENANT_ID"
    output "Subscription ID : $SUB_ID"
    output "Application Client ID : $APP_CLIENT_ID"
}

# この関数は、スクリプトの使い方を出力するためのものです。
usage() {
    output "\nThis script is used to create and configure an Entra app to interact with other IDP such as Github identity provider for operate Azure Resources from Github Actions CI/CD workflows."
    output "In order to this, this script creates the Entra application and its service principal, assign a contributor role of the resource group specified parameter to the application, and create federated credentials for the application to exhcnage tokens with OIDC between other IDP."
    output "\nUsage: $0 [options]"
    output "\nOptions:"
    output "  --rg-name <name> : Specify the resource group name."
    output "  --app-name <name> : Specify the application name."
    output "  --verbose : Enable verbose mode."
    output "  --help : Display this help message."
    output "\nex. $0 --rg-name RagSystem --app-name GithubActions --verbose"
    output "\nAs the result, this script will output the Tenant ID, Subscription ID, and Application Client ID to be set as the other IDP's secrets."
    exit 1
}

# parse arguments.
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --rg-name)
            RG_NAME="$2"
            shift 2
            ;;
        --app-name)
            APP_NAME="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE_MODE=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done
# 必須パラメータが指定されているか確認
if [ -z "$RG_NAME" ]; then
    echo "--rg-name is required."
    usage
    exit 1
fi
if [ -z "$APP_NAME" ]; then
    echo "--app-name is required."
    usage
    exit 1
fi

main
