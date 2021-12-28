//SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.6.0 <= 0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

contract BNS is ERC1155{
    uint public nft_ids;
    uint public token_ids = 1000;
    uint public token_sold;
    address public owner;
    uint totalSupply = 100000;
    // string name;
    // string symbol;


    constructor() ERC1155("") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not authorized");
        _;
    }

    struct nft_detail{
        address owner;
        string name;
    }

    struct tlds{
        address owner;
        string label;
        uint parentId;
        string url;
        bool readyToBeSold;
        uint price;
    }


    mapping(uint => nft_detail) public Zones;
    
    mapping(uint => tlds) public TLDs;

    function createZone(string memory _name) onlyOwner public {
        // name = _name;
        // symbol = _symbol;

        for(uint i = 0; i <= nft_ids; i++){
            require(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked(Zones[i].name)), "Zone Already Exists!");
        }
        nft_ids = nft_ids + 1;

        Zones[nft_ids] = nft_detail(msg.sender, _name);

        _mint(msg.sender, nft_ids, 1, "");

        //NFT Created!
    }

    function createTld(string memory label, uint parentId, string memory uri) public {
        for(uint i = 1000; i <= token_ids; i++){
            require(keccak256(abi.encodePacked(label)) != keccak256(abi.encodePacked(TLDs[i].label)), "Domain/Subdomain Already Exists!");
        }
        // token_ids = uint(keccak256(abi.encodePacked(block.timestamp + 5))) % 10000000000000;
        token_ids = token_ids + 1;

        TLDs[token_ids] = tlds(msg.sender, label, parentId, uri, false, 0);

        _mint(msg.sender, token_ids, 1, bytes(uri));

    //New Domain and Label Created!
    }

    function issueIco(uint tokenId, uint _totalSupply) public {
        _mint(msg.sender, tokenId, _totalSupply, "");

        reserveForAdmin(tokenId);
    }

    function reserveForAdmin(uint tokenId) public {
        // reserveForAdmin(token_ids);
        tokenId = tokenId + 2;
        uint iotricShare = (totalSupply * 10)/ 100;
        safeTransferFrom(msg.sender, owner, tokenId, iotricShare, "");
    }

    function sellTld(uint tokenId, uint price) public {
        require(TLDs[tokenId].owner == msg.sender, "You are not Authorised");
        TLDs[tokenId].readyToBeSold = true;
        TLDs[tokenId].price = price;
        safeTransferFrom(msg.sender, address(0), tokenId, 1, "");
    }

    function buyTld(uint tokenId) public {
        TLDs[tokenId].owner = msg.sender;
        TLDs[tokenId].readyToBeSold = false;
        safeTransferFrom(address(0), msg.sender, tokenId, 1, "");
        token_sold = token_sold + 1;
    }

}