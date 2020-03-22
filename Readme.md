This project demonstrates:
- Azure Pipeline as Code, which creates the infrastructure in Azure through Azure CLI, and publishes the web job to Azure
- Web job to consume incoming message from Azure Queue

Used Azure components:
1) Web app
2) Application Insights
3) Storage account - queue

## Note
- Need app service to run in Windows OS because web jobs are not supported currently in Linux OS.
- For continuous web jobs, enable 'Always On' the app service

## Reference
- https://docs.microsoft.com/en-us/azure/app-service/webjobs-sdk-get-started
- https://docs.microsoft.com/en-us/azure/app-service/webjobs-sdk-how-to
- https://docs.microsoft.com/en-us/azure/app-service/webjobs-dotnet-deploy-vs#webjob-types
- https://markheath.net/post/automate-app-insights-extension