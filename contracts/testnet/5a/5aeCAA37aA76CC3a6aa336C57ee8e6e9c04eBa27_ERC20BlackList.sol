/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev ERC20 contract with temporary blacklisting
 * @author https://github.com/JediFaust
 */
contract ERC20BlackList {
    address owner;
    uint8 private _decimals;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint256) private blackListedUntil;

    event Transfer(address indexed from, address to, uint256 amount);
    event Approval(address indexed owner, address indexed to, uint256 amount);

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_
    ) {
        owner = msg.sender;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;

        _mint(msg.sender, initialSupply_);
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Owner only");
        _;
    }


    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function decimals() external view returns(uint8) {
        return _decimals;
    }

    function totalSupply() external view returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address of_) external view returns(uint256) {
        return balances[of_];
    }


    function transfer(address to_, uint256 amount_)
        external returns(bool)
    {
        _transfer(msg.sender, to_, amount_);

        return true;
    }


    function transferFrom(address from_, address to_, uint256 amount_)
        external returns(bool)
    {
        if(msg.sender != from_) {
            require(allowances[from_][msg.sender] >= amount_, "Not allowed amount");
            allowances[from_][msg.sender] -= amount_;
        }

        _transfer(from_, to_, amount_);

        return true;
    }


    function _transfer(address from_, address to_, uint256 amount_) internal {
        require(from_ != address(0) && to_ != address(0), "Can't be zero address");
        require(balances[from_] >= amount_, "Not enough balance");
        require(
            blackListedUntil[from_] < block.timestamp
            && blackListedUntil[to_] < block.timestamp,
            "Blacklisted!"
        );

        balances[from_] -= amount_;
        balances[to_] += amount_;

        emit Transfer(from_, to_, amount_);
    }
    

    function approve(address to_, uint256 amount_) external returns(bool) {
        require(balances[msg.sender] >= amount_, "Not enough balance");

        allowances[msg.sender][to_] = amount_;

        emit Approval(msg.sender, to_, amount_);

        return true;
    }

    function allowance(address owner_, address spender_) external view returns(uint256) {
        return allowances[owner_][spender_];
    }


    function burn(uint256 amount_) external returns(bool) {
        require(balances[msg.sender] >= amount_, "Not enough balance");

        balances[msg.sender] -= amount_;
        _totalSupply -= amount_;

        emit Transfer(msg.sender, address(0), amount_);

        return true;
    }


    function mint(address to_, uint256 amount_) external onlyOwner {
        _mint(to_, amount_);
    }
    
    function _mint(address to_, uint256 amount_) internal {
        require(to_ != address(0), "Mint to zero address!");
        
        balances[to_] += amount_;
        _totalSupply += amount_;

        emit Transfer(address(0), to_, amount_);
    }

    /**
     * @dev temporary blacklisting functionality
     */
    function temporaryBlackList(address poorman_, uint256 for_) external onlyOwner {
        blackListedUntil[poorman_] = block.timestamp + for_;
    }

    /**
     * @dev permanently blacklisting functionality
     */
    function permanentBlackList(address poorman_) external onlyOwner {
        blackListedUntil[poorman_] = type(uint256).max;
    }

}