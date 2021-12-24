pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

contract BNS is ERC1155{
    uint public nft_ids;
    uint public token_ids;
    uint public token_sold;
    address public owner;

    constructor() ERC1155("Iotric") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not authorized");
        _;
    }

    struct nft_detail{
        address owner;
        string name;
        string types;
    }

    struct tlds{
        address owner;
        string label;
        uint parentId;
        string url;
        bool readyToBeSold;
        uint price;
        string types;
    }
    mapping(uint => nft_detail) public Zones;
    mapping(uint => tlds) public TLDs;
    mapping(address => uint) public balances;

    function createZone(string memory name) onlyOwner public {
        for(uint i = 0; i < nft_ids; i++){
            require(keccak256(abi.encodePacked(name)) != keccak256(abi.encodePacked(Zones[i].name)), "Domain Already Exists!");
        }
        nft_ids = nft_ids + 1;

        Zones[nft_ids] = nft_detail(msg.sender, name);

        _mint(msg.sender, nft_ids, 1, "");
        balances[msg.sender] = 1;
        //NFT Created!
    }

    function createTld(string memory label, uint parentId, string memory uri, uint totalSupply) public {
        for(uint i = 0; i < token_ids; i++){
            require(keccak256(abi.encodePacked(label)) != keccak256(abi.encodePacked(TLDs[i].label)));
        }
        token_ids = token_ids + 1;

    TLDs[token_ids] = tlds(msg.sender, label, parentId, uri, false, 0);

    _mint(msg.sender, token_ids, totalSupply, bytes(uri));
    
    balances[msg.sender] = totalSupply;
    //New Domain and Label Created!
    }

    function balanceOf(address user, uint amount, string memory types, uint tokenId) public {
        if (types == Zones[tokenId].types) {
            return balances[user];
        }
        else if(types == TLDs[tokenId].types) {
            return balances[user];
        }
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