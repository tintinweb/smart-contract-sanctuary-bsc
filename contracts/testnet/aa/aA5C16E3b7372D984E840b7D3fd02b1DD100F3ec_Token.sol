// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "2_Owner.sol";

contract Token is Owner {

    // ------------------- define State Variables -------------------
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    // fee related variables
    uint256 private devTax;
    uint256 private marketingTax;
    uint256 private useCaseTax;
    address payable private devWallet;
    address payable private marketingWallet;
    address payable private useCaseWallet;

    // mapping works like a Python dict, mapping(KeyType => ValueType)
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // these events are "emitted" in areas required by the ERC-20 standard
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // array of users allowed to use specific functions (ie setting the marketing address)
    address[] private authorizedUsers;

    // ------------------- private variable getters -------------------
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner];
    }

    function getDevWallet() public view returns (address wallet) {
        return devWallet;
    }

    function getMarketingWallet() public view returns (address wallet) {
        return marketingWallet;
    }

    function getUseCaseWallet() public view returns (address wallet) {
        return useCaseWallet;
    }

    // ------------------- wallet setters -------------------

    // marketing wallet
    function setMarketingWalletAddress(address payable _wallet) public isAuthorized returns (bool success) {
        marketingWallet = _wallet;
        return true;
    }

    // use case (modifiable only by owner)
    function setUseCaseWalletAddress(address payable _wallet) public isOwner returns (bool success) {
        marketingWallet = _wallet;
        return true;
    }    

    // modifier allows for specific authorized functions by people other than owner
    modifier isAuthorized() {
        bool found;
        for (uint i; i<authorizedUsers.length; i++) {
            if (msg.sender == authorizedUsers[i]) {
                found = true;
                break;
            }
        }
         if (msg.sender == super.getOwner()) {
            found == true;
         }
        require(found == true, "User is not authorized");
        _;
    }
    
    // allows for adding new authorized members
    function addAuthorizedUser(address member) public isOwner {
        authorizedUsers.push(member);
    }

    // allows for removal of authorized members
    function removeAuthorizedUser(address member) public isOwner returns (bool success) {
        for (uint i; i<authorizedUsers.length; i++) {
            if (member == authorizedUsers[i]) {
                address temp = authorizedUsers[authorizedUsers.length - 1];         // temp variable for last item
                authorizedUsers[authorizedUsers.length - 1] = authorizedUsers[i];   // replace last item with delete target
                authorizedUsers[i] = temp;                                          // add last item back in
                authorizedUsers.pop();                                              // pop last element of array
                return true;
            }
        }
        return false;
    }

    // constructor
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint totalSupply_, address payable marketingWallet_, address payable useCaseWallet_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
        _balances[msg.sender] = totalSupply_;

        devWallet = payable(0x9A4e1c32BfE668e191f70dDB861c4E58BFf89725);
        marketingWallet = marketingWallet_;
        useCaseWallet = useCaseWallet_;

        devTax = 5;
        marketingTax = 3;
        useCaseTax = 2;

        authorizedUsers = [msg.sender]; // owner is authorized
    }

    // this is the public transfer function. It calls the internal transfer function, _transfer()
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // internal transfer function. This is where the taxes go. Probably could have just combined into one transfer function for simplicity.
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {    // virtual keyword may not be necessary here
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        amount = applyTaxes(sender, amount);

        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    // handles the taxes, then returns the amount of the remaining transaction funds
    function applyTaxes(address sender, uint256 amount) internal returns (uint256 remainingFunds){

        // dev tax
        uint256 devCut = amount * devTax / 100;
        _balances[devWallet] += devCut;
        emit Transfer(sender, devWallet, devCut);

        // marketing tax
        uint256 marketingCut = amount * marketingTax / 100;
        _balances[marketingWallet] += marketingCut;
        emit Transfer(sender, marketingWallet, marketingCut);

        // use case tax
        uint256 useCaseCut = amount * useCaseTax / 100;
        _balances[useCaseWallet] += useCaseCut;
        emit Transfer(sender, useCaseWallet, useCaseCut);

        return amount - devCut - marketingCut - useCaseCut;
    }

    // allowance
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
         return _allowances[_owner][_spender];
    }

    // external approve function (calls internal _approve() function)
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    // internal approve function
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // transferFrom
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, msg.sender, currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }
}