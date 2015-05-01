#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

/* Shell includes */
//#include "shell.h"

void loop_task(void * pvParameters)
{
	while(1){}

	vTaskDelete(NULL);
}

int main( void )
{

	/*Create a task*/
	xTaskCreate(loop_task,
			   (const char * const) "A Looping Task",
			   512 /*stack size*/, NULL, tskIDLE_PRIORITY + 2, NULL);

	/*Start running the tasks.*/
	vTaskStartScheduler();

	return 0;
}

void vApplicationTickHook()
{
}
