## Runbooks - WIP

These are a couple of scripts to run against one or many clients to enumerate or compromise hosts within an environment.

### Sippin'

This script is a slow trickle of commands to run through our proxy to the targets. There is a randomized timer that pushes commands out between 2-90 minutes. This is to allow a tester to kick of the script and allow it to run in the background. With randomness within the C2, it should allow a little bit more stealth.

### Annaihilation

This is a loud and proud flood of commands within a short period of time to compromise a host as fast as possible without breaking the C2 infrastructure, incuring massive cloud fees, or bricking client boxes. Since this is a bash script, tweak as neccessary; but remember that the intervals set are minimum recomendations to ensure that things don't break. This is a last ditch effort to compromise a machine in a pinch and really shouldn't be the first item to grab.
