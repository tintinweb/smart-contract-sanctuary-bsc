/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

/**

██╗     ██╗███╗   ██╗███████╗  
██║     ██║████╗  ██║██╔════╝  
██║     ██║██╔██╗ ██║█████╗   
██║     ██║██║╚██╗██║██╔══╝   
███████╗██║██║ ╚████║███████╗  
╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝  
                                                                                                              
 */
//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.10;

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function safeMint(address to, string memory uri) external returns (uint256);
}

// Presale Contract
contract LineNftPresale {
    address payable public owner;
    address payable public feeReceiver;
    address public nft;

    address[] public allUsers;
    string[] uri = [
        "https://ipfs.io/ipfs/QmZqYNjVkAmFgFxLLfN7ntXXeAY577yHpTxNQDP7YBmNp8",
        "https://ipfs.io/ipfs/QmVaZMSYs7iR7XbWSXr1KUcz1bJ4ZGey4o7S6BmNUAmyCH",
        "https://ipfs.io/ipfs/QmcWzarzDRxJowXSeajeXQiE8YDfU3hwBV8kev4vxC5tqU"
    ];
    uint256[3] public fee = [2 ether, 5 ether, 15 ether];
    uint256 public totalRaised;
    uint256 public totalSold;
    uint256 public totalUsers;

    struct user {
        uint256 totalInvested;
        uint256[3] totalBought;
    }

    mapping(address => user) internal users;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    constructor(
        address _owner,
        address _feeReceiver,
        address _nft
    ) {
        owner = payable(_owner);
        feeReceiver = payable(_feeReceiver);
        nft = _nft;
    }

    // to buy Nft => for web3 use
    function buyNft(uint256 _index, uint256 _count) public payable {
        require(_count > 0, "Must be greater than 0");
        require(_index >= 0 && _index <= 2, "Invalid index");
        require(msg.value == fee[_index] * _count, "Invalid fee amount");
        feeReceiver.transfer(msg.value);
        if (users[msg.sender].totalInvested == 0) {
            totalUsers++;
            allUsers.push(msg.sender);
        }
        for (uint256 i = 0; i < _count; i++) {
            IERC721(nft).safeMint(msg.sender, uri[_index]);
        }
        users[msg.sender].totalInvested += msg.value;
        totalRaised += msg.value;
        users[msg.sender].totalBought[_index] += _count;
        totalSold += _count;
    }

    // to change  time
    function setFee(
        uint256 _first,
        uint256 _second,
        uint256 _third
    ) external onlyOwner {
        fee[0] = _first;
        fee[1] = _second;
        fee[2] = _third;
    }

    function userData(address _user)
        public
        view
        returns (
            uint256 _totalInvested,
            uint256 _nft1,
            uint256 _nft2,
            uint256 _nft3
        )
    {
        _totalInvested = users[_user].totalInvested;
        _nft1 = users[_user].totalBought[0];
        _nft2 = users[_user].totalBought[1];
        _nft3 = users[_user].totalBought[2];
    }

    function updateValues(
        uint256 _1,
        uint256 _2,
        uint256 _3
    ) external onlyOwner {
        totalRaised = _1;
        totalSold = _2;
        totalUsers = _3;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // change Fee Receiver
    function changeFeeReceiver(address _new) external onlyOwner {
        feeReceiver = payable(_new);
    }

    // to draw funds bnb
    function transferFundsBNB(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }
}