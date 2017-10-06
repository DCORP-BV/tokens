var _ = require("lodash");

module.exports = {
  errors: {
    throws: function(error, message) {
        return new Promise((resolve, reject) => {
            if (error.toString().indexOf("invalid opcode") > -1) {
                return resolve("Expected evm error")
              } else {
                  throw Error(message + " (" + error + ")"); // Different exeption thrown
              }
        });
    }
  },
  events: {
    get: function(contract, filter) {
        return new Promise((resolve, reject) => {
            var event = contract[filter.event]();
            event.watch();
            event.get((error, logs) => {
                var log = _.filter(logs, filter);
                if (log.length > 0) {
                    resolve(log);
                } else {
                    throw Error("No logs found for " + filter.event);
                }
            });
            event.stopWatching();
        });
    },
    assert: function(contract, filter) {
        return new Promise((resolve, reject) => {
            var event = contract[filter.event]();
            event.watch();
            event.get((error, logs) => {
                var log = _.filter(logs, filter);
                if (log.length == 1) {
                    resolve(log);
                } else if (log.length > 0) {
                    throw Error("Multiple events found for " + filter.event);
                } else {
                    throw Error("Failed to find filtered event for " + filter.event);
                }
            });
            event.stopWatching();
        });
    }
  }
}