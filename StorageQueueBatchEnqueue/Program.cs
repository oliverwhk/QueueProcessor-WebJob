using System;
using System.IO;
using Microsoft.Azure.Storage;
using Microsoft.Azure.Storage.Queue;
using Microsoft.Extensions.Configuration;

namespace StorageQueueBatchEnqueue
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Storage queue batch enqueue:");
            Console.WriteLine();

            var config = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .Build();

            var azureWebJobStorage = config["ConnectionStrings:AzureWebJobsStorage"];
            var storageAccount = CloudStorageAccount.Parse(azureWebJobStorage);
            var queueClient = storageAccount.CreateCloudQueueClient();
            var queue = queueClient.GetQueueReference("queue1");
            queue.CreateIfNotExists();

            for (int i = 0; i < 10; i++)
            {
                var message = $"Hello, World {i+1}";
                var queueMessage = new CloudQueueMessage(message);
                queue.AddMessage(queueMessage);
                Console.WriteLine($"Adding message: '{message}'");
            }
            
            Console.WriteLine();
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
        }
    }
}
