// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Licence is ERC1155 {
    using Counters for Counters.Counter;

    Counters.counter private _tokensId;

    struct SplitReceiver {
    address wallet;
    uint256 percentage;
}

    struct LicenceStruct {
    string uri;
    uint256 amount;
    SplitReceiver[] splitReceivers;
}

    mapping (uint256 => address) private _tokenCreators;
    mapping (uint256 => string) private _tokenURIs;
    mapping (uint256 => SplitReceiver) private _splitReceivers;



    constructor() public ERC1155("") {}

function createNew(LicenceStruct[] licenseList) public returns(uint) {
    for (uint256 i = 0; i < licenseList.length; ++i) {
        LicenceStruct licence = licenseList[i];
        _tokensId.increment();
        uint256 idToUse = _tokensId.current();
        _mint(_msgSender(), idToUse, licence.amount);
        _tokenCreators[idToUse] = _msgSender();
        _tokenURIs[uint256] = licence.uri;
        _splitReceivers[idToUse] = licence.splitReceivers;
    }
}


}