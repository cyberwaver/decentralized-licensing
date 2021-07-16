// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Licence is ERC1155 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokensId;
    Counters.Counter private _songsId;

    struct SplitReceiver {
        address payable wallet;
        uint256 percentage;
    }

    struct Song {
        uint256 id;
        address creator;
        uint256 createdAt;
        string uri;
        uint256[] licenceTokenIds;
    }

    struct LicenceToken {
        uint256 id;
        string uri;
        uint256 quantity;
        address creator;
        bool isActive;
        uint256 dateCreated;
        uint256 etherAmount;
        uint256 songId;
        uint256 remunerationBalance;
        SplitReceiver[] splitReceivers;
    }

    struct TokenOwnership {
        uint256 datePurchased;
        uint256 dateRenewed;
    }

    // Mapping from token ID to account balances
    mapping (uint256 => LicenceToken) public _licenceTokens;
    mapping (uint256 => Song) public _songs;
    //address => list of song IDs
    mapping (address => uint256[]) public _addressSongIds;
    mapping (string => uint256[]) public _groupTokens;
    mapping (address => mapping (uint256 => TokenOwnership)) public _addressTokens;

    event LicenceTokenCreated(uint256 indexed tokenId);
    event LicenceTokenPurchased(uint256 indexed tokenId, address indexed purchaser, uint256 amountPaid, uint256 remunerationBalance);
    event LicenceTokenRenewed(uint256 indexed tokenId, address indexed renewer, uint256 amountPaid, uint256 dateRenewed);
    event LicenceTokenSplitReceiversUpdated(uint256 indexed tokenId, SplitReceiver[] splitReceivers);
    event LicenceTokenURIUpdated(uint256 indexed tokenId, string uri);
    event SongAdded(uint256 indexed songId, address indexed creator);
    event SongURIUpdated(uint256 indexed songId, string uri);

    modifier tokenCreatorNotAllowed(uint256 tokenId) {
        require(_msgSender() != _licenceTokens[tokenId].creator, "ERC1155: token creator is not allowed");
        _;
    }

    modifier licenceTokenShouldBeActive(uint256 tokenId) {
        require(_licenceTokens[tokenId].isActive == false, "ERC1155: licence token is inactive");
        _;
    }

    modifier licenceTokenShouldBeInactive(uint256 tokenId) {
        require(_licenceTokens[tokenId].isActive == true, "ERC1155: licence token is active");
        _;
    }

    constructor() ERC1155("") {}

    function _transferLicenceToken(uint tokenId, address receiver) private returns(bool) {
        address tokenCreator = _licenceTokens[tokenId].creator;
        _safeTransferFrom(tokenCreator, receiver, tokenId, 1, "");
        return true;
    }

    function _setTokenSplitReceiver(SplitReceiver[] memory splitReceivers, uint256 tokenId) private {
        for (uint256 i = 0; i < splitReceivers.length; ++i) {
            uint256 currentIndex = _licenceTokens[tokenId].splitReceivers.length;
            _licenceTokens[tokenId].splitReceivers.push();
            _licenceTokens[tokenId].splitReceivers[currentIndex] = SplitReceiver(splitReceivers[currentIndex].wallet, splitReceivers[currentIndex].percentage);
        }
    }

    function _remunerateTokenSplitReceivers(uint256 tokenId) private returns(uint256) {
        SplitReceiver[] memory splitReceivers = _licenceTokens[tokenId].splitReceivers;
        uint256 tokenEtherAmount = _licenceTokens[tokenId].etherAmount;
        for(uint256 i = 0; i < splitReceivers.length; ++i) {
            SplitReceiver memory splitReceiver = splitReceivers[i];
            uint256 receiverEtherRenumeration = (splitReceiver.percentage/100) * tokenEtherAmount;
            splitReceiver.wallet.transfer(receiverEtherRenumeration);
            tokenEtherAmount = tokenEtherAmount - receiverEtherRenumeration;
        }
        return tokenEtherAmount;
    }

    function addNewSong(string memory songURI) public {
        address operator = _msgSender();
        _songsId.increment();
        uint256 songId = _songsId.current();
        _songs[songId].id = songId;
        _songs[songId].uri = songURI;
        _songs[songId].creator = operator;
        _songs[songId].createdAt = block.timestamp;
        _addressSongIds[operator].push(songId);
        emit SongAdded(songId, operator);
    }

    function updateSongURI(uint256 songId, string memory songURI) public {
        _songs[songId].uri = songURI;
        emit SongURIUpdated(songId, songURI);
    }

    function createNewLicenceToken(
        string memory tokenURI, 
        uint256 quantity, 
        uint256 etherAmount, 
        uint256 songId, 
        SplitReceiver[] memory splitReceivers
    ) public {
        address operator = _msgSender();
        _tokensId.increment();
        uint256 tokenId = _tokensId.current();
        _mint(operator, tokenId, quantity, "");
        _licenceTokens[tokenId].dateCreated = block.timestamp;
        _licenceTokens[tokenId].etherAmount = etherAmount;
        _licenceTokens[tokenId].songId =songId;
        _licenceTokens[tokenId].uri = tokenURI;
        _licenceTokens[tokenId].quantity = quantity;
        _licenceTokens[tokenId].creator = operator;
        _setTokenSplitReceiver(splitReceivers, tokenId);
        _songs[songId].licenceTokenIds.push(tokenId);
        emit LicenceTokenCreated(tokenId);
}

    function updateLicenceTokenURI(uint256 tokenId, string memory tokenURI) public {
        _licenceTokens[tokenId].uri = tokenURI;
        emit LicenceTokenURIUpdated(tokenId, tokenURI);
    }

    function updateLicenceTokenSplitReceivers(uint256 tokenId, SplitReceiver[] memory splitReceivers) public {
        _setTokenSplitReceiver(splitReceivers, tokenId);
        emit LicenceTokenSplitReceiversUpdated(tokenId, splitReceivers);
    }


    function isLicencePurchasable(uint256 tokenId) public view returns(bool) {
        LicenceToken memory token = _licenceTokens[tokenId];
        if(token.isActive == false) return false;
        if(super.balanceOf(token.creator, tokenId) == 0) return false;
        return true;
    }

    function purchaseLicence(uint256 tokenId) external payable licenceTokenShouldBeActive(tokenId) tokenCreatorNotAllowed(tokenId) {
        uint256 tokenEtherAmount = _licenceTokens[tokenId].etherAmount;
        require(tokenEtherAmount == msg.value, "ERC1155: incorrect amount of ether sent");
        address operator = _msgSender();
        _transferLicenceToken(tokenId, operator);
        uint256 remunerationBalance = _remunerateTokenSplitReceivers(tokenId);
        _licenceTokens[tokenId].remunerationBalance += remunerationBalance;
        _addressTokens[operator][tokenId].datePurchased = block.timestamp;
        emit LicenceTokenPurchased(tokenId, operator, tokenEtherAmount, remunerationBalance);
    }

    function renewLicence(uint256 tokenId) external payable licenceTokenShouldBeActive(tokenId) tokenCreatorNotAllowed(tokenId) {
        uint256 tokenEtherAmount = _licenceTokens[tokenId].etherAmount;
        require(tokenEtherAmount == msg.value, "ERC1155: incorrect amount of ether sent");
        address operator = _msgSender();
        _transferLicenceToken(tokenId, operator);
        uint256 remunerationBalance = _remunerateTokenSplitReceivers(tokenId);
        _licenceTokens[tokenId].remunerationBalance += remunerationBalance;
        _addressTokens[operator][tokenId].dateRenewed = block.timestamp;
        emit LicenceTokenRenewed(tokenId, operator, tokenEtherAmount, block.timestamp);
    }

    function uri(uint256 tokenId) public view override returns(string memory) {
        return _licenceTokens[tokenId].uri;
    }

    function getToken(uint256 tokenId) public view returns(LicenceToken memory) {
        return _licenceTokens[tokenId];
    }  

    function getAddressSongIds(address songId) public view returns(uint256[] memory) {
        return _addressSongIds[songId];
    }  

    // function safeTransferFrom() public {
    //     revert("Token transfer blocked");
    // }



}