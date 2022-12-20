/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

/**
 * @title HeisenVerse SwishFish Marketplace
 * @author HeisenDev
 */
contract SwishFishMarketplaceBNB {
    address private _heisen;
    address  private _project;
    string[] public _orders;
    uint8 public _tax = 10;
    mapping (string => bool) public _is_closed; 
    event Deposit(address indexed sender, uint amount);
    event Withdraw(address indexed sender, uint amount);
    event BuyNFT(string hash, address buyer,address seller, uint amount);
    event BuyItem(string hash, address buyer,address seller, uint amount);

    constructor(address project_) {
        _heisen = msg.sender;
        _project  = payable(project_);
    }

    /// @dev Fallback function allows to deposit ether.
    receive() external payable {
        if (msg.value > 0) {
            emit Deposit( msg.sender, msg.value);
        }
    }

    modifier onlyHeisen(){
        require(msg.sender == _heisen);
        _;
    }

    function buyNFT(string memory hash_, address seller_) public payable {
        require(msg.value > 0, "Marketplace: Underpriced");
        uint256 amount = msg.value;
        bytes32 order_id = keccak256(abi.encodePacked(hash_, seller_, amount));
        string memory order_id_str = string(abi.encodePacked(order_id));
        require(!_is_closed[order_id_str], "Marketplace: Order is closed");

        _orders.push(order_id_str);
        _is_closed[order_id_str] = true;

        uint256 amount_seller = amount * (100 - _tax) / 100;
        (bool sent,) = seller_.call{value : amount_seller}("");
        require(sent, "Deposit ETH: failed to send ETH");
    
        uint256 amount_project = amount - amount_seller;
        (bool sentp,) = _project.call{value : amount_project}("");
        require(sentp, "Deposit ETH: failed to send ETH");

        emit BuyNFT(hash_, msg.sender, seller_, amount);
    }

    function buyItem(string memory hash_, address seller_) public payable {
        require(msg.value > 0, "Marketplace: underpriced");
        uint256 amount = msg.value;
        bytes32 order_id = keccak256(abi.encodePacked(hash_, seller_, amount));
        string memory order_id_str = string(abi.encodePacked(order_id));
        _orders.push(order_id_str);
        _is_closed[order_id_str] = true;
        uint256 amount_seller = amount * (100 - _tax) / 100;
        (bool sent,) = seller_.call{value : amount_seller}("");
        require(sent, "Deposit ETH: failed to send ETH");
        emit BuyItem(hash_, msg.sender, seller_, amount);
    }
    
    function updateProjectAddress(address project_) external onlyHeisen {
        _project  = project_;

    }
    
    function projectPayment() external onlyHeisen {
        uint256 amount = address(this).balance;
        (bool sent,) = _project.call{value : amount}("");
        require(sent, "Deposit ETH: failed to send ETH");
        emit Withdraw( _project, amount);

    }
}