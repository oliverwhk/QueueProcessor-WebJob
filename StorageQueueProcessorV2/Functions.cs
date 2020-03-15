using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace StorageQueueProcessorV2
{
    public class Functions
    {
        public static async Task ProcessQueueMessage([QueueTrigger("queue1")] string message, ILogger logger)
        {
            logger.LogInformation($"ProcessQueueMessage: Processing message '{message}'...");

            await Task.Delay(2 * 60 * 1000);
            
            logger.LogInformation($"ProcessQueueMessage: Finished processing message '{message}'.");
        }
    }
}
