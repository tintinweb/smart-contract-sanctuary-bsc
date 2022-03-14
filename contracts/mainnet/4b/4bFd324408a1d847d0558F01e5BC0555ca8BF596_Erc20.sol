// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./SafeMath.sol";
import "./Ownable.sol";

/**
 * @title ERC20 token module
 * @dev This is the standard interface for ERC20
 */
contract Erc20 is Ownable {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    string name_ = "MetaCoin";
    string symbol_ = "Mit";
    uint32 decimals_ = 8;
    uint256 totalSupply_ = 10000000000 * (10 ** decimals_);
    uint256 initialSupply_ = 10000000000 * (10 ** decimals_);

    // rate ratio 1:10000 (fixed)
    uint32 ratio_ = 10000;
    // commission rate 3 means 3/10,000
    uint32 rate_ = 0;
    // maximum fee
    uint256 feeMax_ = 10000000 * (10 ** decimals_);

    // fee statistics
    uint256 feeCount_;

    // address => uint256
    mapping(address => uint256) balances;

    // _owner => _operator => uint256
    mapping(address => mapping(address => uint256)) allowed;

    // _owner => _amount
    mapping(address => uint256) frozenAccount;

    /*
     * @dev constructor, issue ERC20 tokens
     * @param {Number} _totalSupply total supply
     * @param {Number} _initialSupply initial get
     * @param {String} _tokenName name
     * @param {String} _tokenSymbol symbol
     * @param {String} _decimals precision
     */
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint32 _decimals,
        uint256 _totalSupply,
        uint256 _initialSupply
    ) {
        decimals_ = _decimals;
        initialSupply_ = _initialSupply * 10**decimals_;
        totalSupply_ = _totalSupply * 10**decimals_;
        name_ = _tokenName;
        symbol_ = _tokenSymbol;
        // Transfer assets to originating account
        balances[msg.sender] = initialSupply_;
    }

    /*
     * @dev event notification - freeze assets
     * @param {String} _address destination address
     * @param {Number} _amount frozen amount
     */
    event Frozen(address _address, uint256 _amount);

    /*
     * @dev event notification - transaction occurred
     * @param {String} _from
     * @param {String} _to
     * @param {Number} _amount
     */
    event Transfer(address _from, address _to, uint256 _amount);

    /*
     * @dev event notification - authorization change
     * @param {String} _owner
     * @param {String}_operator
     * @param {Number} _amount
     */
    event Approval(address _owner, address _operator, uint256 _amount);

    /*
     * @dev event notification - additional tokens
     * @param {String} _address The address for receiving additional coins
     * @param {String} _amount additional issuance amount
     */
    event Mint(address _address, uint256 _amount);

    /*
     * @dev event notification - destroyed tokens
     * @param {String} _address destination address
     * @param {Number} _amount The amount destroyed
     */
    event Burn(address _address, uint256 _amount);

    /**
     * @dev query token name
     */
    function name() public view returns (string memory) {
        return name_;
    }

    /**
     * @dev query token symbol
     */
    function symbol() public view returns (string memory) {
        return symbol_;
    }

    /**
     * @dev query token precision
     */
    function decimals() public view returns (uint32) {
        return decimals_;
    }

    /**
     * @dev Query the total issuance of tokens
     * @return {Number} returns the issue number
     */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
     * @dev maximum handling fee
     * @return {Number} returns the handling fee
     */
    function feeMax() public view returns (uint256) {
        return feeMax_;
    }

    /*
     * @dev sets the maximum handling fee
     * @param {Number} feeMax Maximum fee
     */
    function setFeeMax(uint256 _feeMax) public onlyOwner {
        // maximum fee
        feeMax_ = _feeMax;
    }

    /**
     * @dev fee rate
     * @return {Number} returns the fee rate
     */
    function rate() public view returns (uint32) {
        return rate_;
    }

    /*
     * @dev set the transfer fee
     * @param {Number} _rate
     */
    function setRate(uint32 _rate) public onlyOwner {
        // Transfer fee
        rate_ = _rate;
    }

    /**
     * @dev query fee
     * @param {Number} _amount amount
     * @return {Number} returns the handling fee
     */
    function getFee(uint256 _amount) public view returns (uint256) {
        if (rate_ == 0) {
            return 0;
        }
        uint256 fee = _amount.div(ratio_) * rate_;
        if (fee > feeMax_) {
            fee = feeMax_;
        }
        return fee;
    }

    /**
         * @dev Query the amount of frozen assets in the account
         * @param {String} _address query address
         */
        function frozenOf(address _address) public view returns (uint256) {
            return frozenAccount[_address];
        }
    
        /**
         * @dev query address balance
         * @param {String}_address
         * @return {Number} returns the balance
         */
        function balanceOf(address _address) public view returns (uint256) {
            return balances[_address];
        }
    
        /**
         * @dev query address available balance
         * @param {String}_address
         * @return {Number} returns the balance
         */
        function balanceUseOf(address _address) public view returns (uint256) {
            uint256 balance = balanceOf(_address);
            uint256 frozen = frozenOf(_address);
            return balance.sub(frozen);
        }
    
        /*
         * @dev pays the handling fee
         * @param {Object} _amount
         */
        function _payFee(uint256 _amount) private {
            uint256 fee = getFee(_amount);
            if (fee > 0) {
                feeCount_ = feeCount_.add(fee);
                balances[owner] = balances[owner].add(fee);
            }
        }
    
        /*
         * @dev transfer
         * @param {String} _from the sender
         * @param {String} _to payee
         * @param {Number} _amount transfer amount
         */
        function _transfer(
            address _from,
            address _to,
            uint256 _amount
        ) private {
            uint256 fee = getFee(_amount);
            // console.log("Handling fee", fee);
            uint256 total = _amount + fee;
            uint256 balance = balanceOf(_from);
            require(balance >= total, "ERC20: insufficient account balance");
            uint256 frozen = frozenOf(_from);
            uint256 _balance = balance.sub(total);
            require(
                balance > frozen && _balance >= frozen,
                "ERC20: Insufficient available balance"
            );
            balances[_from] = _balance;
            balances[_to] = balances[_to].add(_amount);
            emit Transfer(_from, _to, _amount);
        }
    
        /*
         * @dev initiator transfer
         * @param {String} _to the recipient user
         * @param {Number} _amount amount
         */
        function transfer(address _to, uint256 _amount) public {
            require(
                _to != address(0),
                "ERC20: cannot transfer to black hole address"
            );
            require(_to != msg.sender, "ERC20: cannot transfer to self");
            require(_amount > 0, "ERC20: transfer _amount must be greater than 0");
            _transfer(msg.sender, _to, _amount);
            _payFee(_amount);
        }

    /*
         * @dev initiator transfer
         * @param {String} _to payee
         * @param {Number} _amount transfer amount
         */
        function safeTransfer(
            address _to,
            uint256 _amount
        ) public returns(bool){
            transfer(_to,_amount);
            return true;
        }
    
        /*
         * @dev transfer money from an account to someone (public)
         * @param {String} _from the sender
         * @param {String} _to payee
         * @param {Number} _amount transfer amount
         */
        function transferFrom(
            address _from,
            address _to,
            uint256 _amount
        ) public {
            require(_amount > 0, "ERC20: transfer _amount must be greater than 0");
            require(
                allowed[_from][msg.sender] >= _amount,
                "ERC20: Exceed the authorized limit"
            );
            _transfer(_from, _to, _amount);
            _payFee(_amount);
        }
    
          /*
         * @dev transfer money from an account to someone (public)
         * @param {String} _from the sender
         * @param {String} _to payee
         * @param {Number} _amount transfer amount
         */
        function safeTransferFrom(
            address _from,
            address _to,
            uint256 _amount
        ) public returns(bool){
            transferFrom(_from,_to,_amount);
            return true;
        }
    
    
        /*
         * Authorization
         * @param {String} _operator Authorized operator
         * @param {Number} _amount Authorized single actionable amount
         */
        function approve(address _operator, uint256 _amount) public {
            address owner = msg.sender;
            allowed[owner][_operator] = _amount;
            emit Approval(owner, _operator, _amount);
        }
    
        /**
         * @dev query authorization limit
         * @param {String} _owner holder address
         * @param {String} _operator Authorizer address
         * @return {Number} returns the authorized amount
         */
        function allowance(address _owner, address _operator)
            public
            view
            returns (uint256)
        {
            return allowed[_owner][_operator];
        }
    
        /*
         * @dev batch transfer
         * @param {String} _from from someone
         * @param {String} _toArr to someone
         * @param {Number} _amount transfer amount
         */
        function _transferBath(
            address _from,
            address[] memory _toArr,
            uint256 _amount
        ) private {
            uint256 balance = balanceOf(_from);
            uint256 count = _toArr.length.mul(_amount);
            uint256 fee = getFee(count);
            uint256 total = count + fee;
            require(balance >= total, "ERC20: insufficient account balance");
            uint256 frozen = frozenOf(_from);
            require(
                balance > frozen && balance.sub(frozen) >= total,
                "ERC20: insufficient available balance"
            );
            for (uint256 i = 0; i < _toArr.length; i++) {
                address _to = _toArr[i];
                _transfer(_from, _to, _amount);
            }
            _payFee(count);
        }
    
        /*
         * @dev (authorizer) batch transfer
         * @param {String} _from outgoing address
         * @param {String} _toArr collection address collection
         * @param {Number} _amount The amount obtained by each address
         */
        function transferFromBath(
            address _from,
            address[] memory _toArr,
            uint256 _amount
        ) public {
            uint256 n = allowance(_from, msg.sender);
            require(n > 0, "ERC20: No operation permission");
            require(n >= _amount, "ERC20: Exceeds the single actionable _amount");
            _transferBath(_from, _toArr, _amount);
        }
    
        /*
         * @dev batch transfer
         * @param {String} _toArr collection address collection
         * @param {Number} _amount The amount obtained by each address
         */
        function transferBath(address[] memory _toArr, uint256 _amount) public {
            _transferBath(msg.sender, _toArr, _amount);
        }

   /*
        * @dev additional issuance representative
        * @param {String} _address to send to someone
        * @param {Number} _amount The amount of additional issuance
        */
       function mint(address _address, uint256 _amount) public onlyAdmin {
           balances[_address] = balances[_address].add(_amount);
           totalSupply_ = totalSupply_.add(_amount);
           emit Mint(_address, _amount);
           emit Transfer(zeroAddress, owner, _amount);
           emit Transfer(owner, _address, _amount);
       }
   
       /*
        * @dev freeze assets
        * @param {String} _address destination address
        * @param {Number} _amount frozen amount
        */
       function freeze(address _address, uint256 _amount) public onlyAdmin {
           uint256 balance = balanceOf(_address);
           if (_amount > balance) {
               _amount = balance;
           }
           frozenAccount[_address] = _amount;
           emit Frozen(_address, _amount);
       }
   
       /*
        * @dev destroy
        * @param {String} _address account address
        * @param {Number} _amount Destruction amount
        */
       function _burn(address _address, uint256 _amount) private {
           require(
               _address != address(0),
               "ERC20: cannot destroy from zero address"
           );
           balances[_address] = balances[_address].sub(_amount);
           totalSupply_ = totalSupply_.sub(_amount);
           emit Transfer(_address, address(0), _amount);
           // Burn(_address, _amount);
       }
	   
       /*
        * @dev burn someone's tokens
        * @param {String} _address account address
        * @param {Number} _amount Destruction amount
        */
       function burnFrom(address _address, uint256 _amount) public onlyAdmin {
           _burn(_address, _amount);
       }
   
       /*
        * @dev cost statistics
        * @param {String} _address account address
        * @param {Number} _amount Destruction amount
        */
       function feeCount() public view returns (uint256) {
           return feeCount_;
       }
   }