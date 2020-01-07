import mlflow
import mlflow.sklearn

import logging
mlflow.set_tracking_uri('http://mlflow-server.southeastasia.cloudapp.azure.com:5000')
logging.basicConfig(level=logging.WARN)
logger = logging.getLogger(__name__)


if __name__ == "__main__":
    client = mlflow.tracking.MlflowClient()
    model_location = client.get_latest_versions(name = "Model A", stages = ["Production"])[0].source
    print(model_location)

