/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.5;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable {
    address internal owner;
    address private _previousOwner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract MetalShiba_Private is Ownable {

    address public MetalShiba;
    address public treasury;

    string constant public _name                  = "MetalShiba_PrivateSale";
    string constant public ContractCreator = "@FrankFourier";

    mapping (address => uint256) public _balances;
    mapping (address => bool) public whitelisted;

    bool    public Sale_Open;
    bool    public Whitelist_enabled;

    uint256 public _maxWalletToken  = 1 *10**8 * 10 **18;
    uint256 public _privatesaleRate = 168 * 10**5;
    uint256 public MAX_Contribution = 5 * 10**18;
    uint256 public MIN_Contribution = 4 * 10**17;
    uint256 public soldtokens;
    uint256 public HARDCAP          = 50 * 10**18;

    constructor (address _MetalShiba, address _treasury) Ownable(msg.sender) {
        MetalShiba = _MetalShiba;
        treasury   = _treasury;
    }

    receive() external payable {}

    function buy_MetalShiba() payable external {
        require(msg.value <= MAX_Contribution);
        require(msg.value >= MIN_Contribution);
        require(Sale_Open);
        if (Whitelist_enabled == true)
        require(whitelisted[msg.sender]);
        uint256 amount = _privatesaleRate * msg.value;
        require(amount + _balances[msg.sender] <= _maxWalletToken, "Max wallet holding reached");

        if(address(this).balance >= HARDCAP)
        Sale_Open = false;

        _balances[msg.sender] += amount;
        soldtokens += amount;
    }

    function get_amount_decimals(uint256 _BNB) external view returns (uint256) {
        uint256 amount = _privatesaleRate * _BNB;
        return amount;
    }

    function set_sale_status(bool status) external onlyOwner {
        Sale_Open = status;
    }

    function withdrawBNB() external onlyOwner {
        uint256 amount = address(this).balance;
        (bool TreasurySuccess, /* bytes memory data */) = payable(treasury).call{value: amount, gas: 30000}("");
        require(TreasurySuccess, "receiver rejected BNB transfer");
    }

    function whitelistAddress(address[] memory accounts) external onlyOwner {
        for (uint256 account = 0; account < accounts.length; account++) {
            addWhitelisted(accounts[account]);
        }
    }

    function addWhitelisted(address _account) public {
        whitelisted[_account] = true;
    }

    function update_MAX_MIN(uint256 _MAX, uint256 _MIN) external onlyOwner {
        MAX_Contribution = _MAX;
        MIN_Contribution = _MIN;
    } 
}