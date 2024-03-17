import main
import json

# Open the orders.json file
with open("./eb2sns_ecs_deployment.json") as file:
    # Load its content and make a new dictionary
    event = json.load(file)
    context = []
    main.lambda_handler(event, context)