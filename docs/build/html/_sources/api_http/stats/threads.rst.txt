/api/stats/threads
==================
.. index:: HTTP /api/stats/threads
The threads endpoint is used for debugging the TSD and providing insight into the state and execution of various threads without having to resort to a JStack trace. (v2.2)

Verbs
-----

* GET

Requests
--------

No parameters available.

Example Request
^^^^^^^^^^^^^^^

**Query String**
::
  
  http://localhost:4242/api/stats/threads
   
Response
--------
   
The response is an array of objects. Fields in the response include:

.. csv-table::
  :header: "Name", "Data Type", "Description", "Example"
  :widths: 10, 10, 60, 20
  
  "threadID", "Integer", "Numeric ID of the thread", "1"
  "priority", "Integer", "Execution priority for the thread", "5"
  "name", "String", "String name of the thread, usually assigned by default", "New I/O worker #23"
  "interrupted", "Boolean", "Whether or not the thread was interrupted", "false"
  "state", "String", "One of the valid Java thread states", "RUNNABLE"
  "stack", "Array<String>", "A stack trace showing where execution is currently located", "*See Below*"

Example Response
^^^^^^^^^^^^^^^^
.. code-block :: javascript 

  [
      {
          "threadID": 33,
          "priority": 5,
          "name": "AsyncHBase I/O Worker #23",
          "interrupted": false,
          "state": "RUNNABLE",
          "stack": [
              "sun.nio.ch.KQueueArrayWrapper.kevent0(Native Method)",
              "sun.nio.ch.KQueueArrayWrapper.poll(KQueueArrayWrapper.java:136)",
              "sun.nio.ch.KQueueSelectorImpl.doSelect(KQueueSelectorImpl.java:69)",
              "sun.nio.ch.SelectorImpl.lockAndDoSelect(SelectorImpl.java:69)",
              "sun.nio.ch.SelectorImpl.select(SelectorImpl.java:80)",
              "org.jboss.netty.channel.socket.nio.SelectorUtil.select(SelectorUtil.java:68)",
              "org.jboss.netty.channel.socket.nio.AbstractNioSelector.select(AbstractNioSelector.java:415)",
              "org.jboss.netty.channel.socket.nio.AbstractNioSelector.run(AbstractNioSelector.java:212)",
              "org.jboss.netty.channel.socket.nio.AbstractNioWorker.run(AbstractNioWorker.java:89)",
              "org.jboss.netty.channel.socket.nio.NioWorker.run(NioWorker.java:178)",
              "org.jboss.netty.util.ThreadRenamingRunnable.run(ThreadRenamingRunnable.java:108)",
              "org.jboss.netty.util.internal.DeadLockProofWorker$1.run(DeadLockProofWorker.java:42)",
              "java.util.concurrent.ThreadPoolExecutor$Worker.runTask(ThreadPoolExecutor.java:895)",
              "java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:918)",
              "java.lang.Thread.run(Thread.java:695)"
          ]
      },
      {
          "threadID": 6,
          "priority": 9,
          "name": "Signal Dispatcher",
          "interrupted": false,
          "state": "RUNNABLE",
          "stack": []
      },
      {
          "threadID": 21,
          "priority": 5,
          "name": "AsyncHBase I/O Worker #11",
          "interrupted": false,
          "state": "RUNNABLE",
          "stack": [
              "sun.nio.ch.KQueueArrayWrapper.kevent0(Native Method)",
              "sun.nio.ch.KQueueArrayWrapper.poll(KQueueArrayWrapper.java:136)",
              "sun.nio.ch.KQueueSelectorImpl.doSelect(KQueueSelectorImpl.java:69)",
              "sun.nio.ch.SelectorImpl.lockAndDoSelect(SelectorImpl.java:69)",
              "sun.nio.ch.SelectorImpl.select(SelectorImpl.java:80)",
              "org.jboss.netty.channel.socket.nio.SelectorUtil.select(SelectorUtil.java:68)",
              "org.jboss.netty.channel.socket.nio.AbstractNioSelector.select(AbstractNioSelector.java:415)",
              "org.jboss.netty.channel.socket.nio.AbstractNioSelector.run(AbstractNioSelector.java:212)",
              "org.jboss.netty.channel.socket.nio.AbstractNioWorker.run(AbstractNioWorker.java:89)",
              "org.jboss.netty.channel.socket.nio.NioWorker.run(NioWorker.java:178)",
              "org.jboss.netty.util.ThreadRenamingRunnable.run(ThreadRenamingRunnable.java:108)",
              "org.jboss.netty.util.internal.DeadLockProofWorker$1.run(DeadLockProofWorker.java:42)",
              "java.util.concurrent.ThreadPoolExecutor$Worker.runTask(ThreadPoolExecutor.java:895)",
              "java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:918)",
              "java.lang.Thread.run(Thread.java:695)"
          ]
      },
      {
          "threadID": 2,
          "priority": 10,
          "name": "Reference Handler",
          "interrupted": false,
          "state": "WAITING",
          "stack": [
              "java.lang.Object.wait(Native Method)",
              "java.lang.Object.wait(Object.java:485)",
              "java.lang.ref.Reference$ReferenceHandler.run(Reference.java:116)"
          ]
      },
      {
          "threadID": 44,
          "priority": 5,
          "name": "OpenTSDB Timer TSDB Timer #1",
          "interrupted": false,
          "state": "TIMED_WAITING",
          "stack": [
              "java.lang.Thread.sleep(Native Method)",
              "org.jboss.netty.util.HashedWheelTimer$Worker.waitForNextTick(HashedWheelTimer.java:483)",
              "org.jboss.netty.util.HashedWheelTimer$Worker.run(HashedWheelTimer.java:392)",
              "org.jboss.netty.util.ThreadRenamingRunnable.run(ThreadRenamingRunnable.java:108)",
              "java.lang.Thread.run(Thread.java:695)"
          ]
      }
  ]
