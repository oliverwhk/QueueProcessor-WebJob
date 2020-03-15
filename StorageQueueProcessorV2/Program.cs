using System.IO;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace StorageQueueProcessorV2
{
    class Program
    {
        static void Main(string[] args)
        {
            var builder = new HostBuilder();
            builder.ConfigureWebJobs(b =>
            {
                b.AddAzureStorageCoreServices();
                b.AddAzureStorage();
            });
            
            builder.ConfigureAppConfiguration((context, c) =>
            {
                c.SetBasePath(Directory.GetCurrentDirectory())
                 .AddJsonFile("appSettings.json", optional: false, reloadOnChange: true)
                 .AddEnvironmentVariables();
            });
            
            builder.ConfigureLogging((context, b) =>
            {
                b.AddConsole();

                // If the key exists in settings, use it to enable Application Insights.
                string instrumentationKey = context.Configuration["APPINSIGHTS_INSTRUMENTATIONKEY"];
                if (!string.IsNullOrEmpty(instrumentationKey))
                {
                    b.AddApplicationInsightsWebJobs(o => o.InstrumentationKey = instrumentationKey);
                }
            });
            var host = builder.Build();
            using (host)
            {
                host.Run();
            }
        }
    }
}
