var Tester = artifacts.require("Tester");

module.exports = function (deployer) {
  //   console.log("TESTER: ", Tester);
  deployer.deploy(Tester);
};

// [
//   {
//     uri: "QmcrN8DPkox7CpBtQbsPyXUbXWLEkZRc9KpghxpmE5qVsc",
//     quantity: 100,
//     splitReceivers: [{ wallet: "0x9f454ef74309f77D869d4C3e0eC8A2a088da8f62", percentage: 100 }],
//   },
// ];

// [["QmcrN8DPkox7CpBtQbsPyXUbXWLEkZRc9KpghxpmE5qVsc",100,[["0x9f454ef74309f77D869d4C3e0eC8A2a088da8f62",100]]], ["QmcrN8DPkox7CpBtQbsPyXUbXWLEkZRc9KpghxpmE5qVsc",100,[["0x9f454ef74309f77D869d4C3e0eC8A2a088da8f62",100]]]]
// [1626356353938, 1000000000000000000, "urioyyyyya"]
// [["0x9f454ef74309f77D869d4C3e0eC8A2a088da8f62",100], ["0x9f454ef74309f77D869d4C3e0eC8A2a088da8f62",100], ["0x9f454ef74309f77D869d4C3e0eC8A2a088da8f62",100]]