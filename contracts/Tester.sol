// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract Tester {
    struct Appliance {
        string name;
        uint256 load;
    }

    struct AppQty {
        string name;
        uint256 qty;
    }

        struct SplitReceiver {
    address payable wallet;
    uint256 percentage;
}

    struct LicenceStruct {
    string uri;
    uint256 quantity;
}

    Appliance[] appliances;
    LicenceStruct[] licences;


    constructor() {
        appliances.push(Appliance("Electric Stove", 2500));
        appliances.push(Appliance("Microwave", 2500));
        appliances.push(Appliance("Boiler", 2500));
        appliances.push(Appliance("Electric Heater 30-50 liters", 2500));
        appliances.push(Appliance("Electric Heater 10-25 liters", 1500));
        appliances.push(Appliance("Dishwasher", 2000));
        appliances.push(Appliance("Mini Dishwasher", 1000));
        appliances.push(Appliance("Full Automatic Washing Machine", 2500));
        appliances.push(Appliance("Half Automatic Washing Machine", 1250));
        appliances.push(Appliance("Fan", 500));
        appliances.push(Appliance("Refrigerator +14 feet", 2000));
        appliances.push(Appliance("Refrigerator 12-14 feet", 1500));
        appliances.push(Appliance("Refrigerator 8-10 feet", 1000));
    }

    modifier appsLength(AppQty[] memory _appliances) {
        require(_appliances.length > 0);
        _;
    }

    modifier checkApp(string memory _name, uint256 _load) {
        require(keccak256(abi.encodePacked(_name)) != "" && _load > 0);
        _;
    }

    function getAppLoad(string memory _appliance, uint256 _qty)
        private
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < appliances.length; i++) {
            if (
                keccak256(abi.encodePacked(appliances[i].name)) ==
                keccak256(abi.encodePacked(_appliance))
            ) {
                return appliances[i].load * _qty;
            }
        }

        return 0;
    }

    function getAppNames() external view returns (string[] memory) {
        string[] memory appNames = new string[](appliances.length);

        for (uint256 i = 0; i < appliances.length; i++) {
            appNames[i] = appliances[i].name;
        }

        return appNames;
    }

    function addLicences(LicenceStruct memory licence) public returns(bool) {
        LicenceStruct memory newLicence;
        newLicence.uri = licence.uri;
        newLicence.quantity = licence.quantity;
        licences.push(newLicence);
        return true;
    }

    function addAppliance(string memory _name, uint256 _load)
        public
        checkApp(_name, _load)
        returns (bool)
    {
        appliances.push(Appliance(_name, _load));
        return true;
    }
}