import pulumi
import pulumi_gcp
from pulumi import Output, Config
from pulumi_gcp.cloudrun import (
    ServiceTemplateMetadataArgs,
    ServiceTemplateSpecContainerEnvArgs,
)

config = Config()

if config.get_bool("use_cloud_sql"):
    cloud_sql_instance = pulumi_gcp.sql.DatabaseInstance(
        "pgsql-instance",
        database_version="POSTGRES_12",
        deletion_protection=False,  # TODO: True if production
        settings=pulumi_gcp.sql.DatabaseInstanceSettingsArgs(
            tier="db-f1-micro"
        ),  # TODO: from config
    )

    database = pulumi_gcp.sql.Database(
        "database", instance=cloud_sql_instance.name, name=config.require("db-name")
    )

    users = pulumi_gcp.sql.User(
        "users",
        name=config.require("db-name"),
        instance=cloud_sql_instance.name,
        password=config.require_secret(
            "db-password"
        ),  # TODO: Pulumi.random if not specified
    )

    sql_instance_url = Output.concat(
        "postgres://",
        config.require("db-name"),
        ":",
        config.require_secret("db-password"),
        "@/",
        config.require("db-name"),
        "?host=/cloudsql/",
        cloud_sql_instance.connection_name,
    )

    service_annotations = {
        "run.googleapis.com/cloudsql-instances": cloud_sql_instance.connection_name
    }
else:
    service_annotations = {}
    sql_instance_url = config.require("db-url")

cloud_run = pulumi_gcp.cloudrun.Service(
    "vizallas-notebook-service",
    location=Config("gcp").require("region"),
    template=pulumi_gcp.cloudrun.ServiceTemplateArgs(
        metadata=ServiceTemplateMetadataArgs(
            annotations=service_annotations,
        ),
        spec=pulumi_gcp.cloudrun.ServiceTemplateSpecArgs(
            containers=[
                pulumi_gcp.cloudrun.ServiceTemplateSpecContainerArgs(
                    image="tfoldi/vizallas-notebooks",
                    envs=[
                        ServiceTemplateSpecContainerEnvArgs(
                            name="PG_URL",
                            value=sql_instance_url,
                        ),
                        ServiceTemplateSpecContainerEnvArgs(
                            name="JUPYTER_TOKEN", value=config.get("jupyter-token")
                        ),
                    ],
                    ports=[
                        pulumi_gcp.cloudrun.ServiceTemplateSpecContainerPortArgs(
                            container_port=8888,
                        ),
                    ],
                )
            ],
        ),
    ),
    traffics=[
        pulumi_gcp.cloudrun.ServiceTrafficArgs(
            latest_revision=True,
            percent=100,
        )
    ],
)

# Create an IAM member to make the service publicly accessible.
invoker = pulumi_gcp.cloudrun.IamMember(
    "invoker",
    pulumi_gcp.cloudrun.IamMemberArgs(
        location=cloud_run.location,
        service=cloud_run.name,
        role="roles/run.invoker",
        member="allUsers",
    ),
)

if config.get_bool("use_cloud_sql"):
    pulumi.export("pgsql_instance_name", cloud_sql_instance.name)
pulumi.export("cloud_run_url", cloud_run.statuses[0].url)
