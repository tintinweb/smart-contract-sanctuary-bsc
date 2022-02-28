/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

}

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
	
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
	
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
		    _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
		
    }
	
}

interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IMARLO is IBEP20 {
  
    function sell(uint256 amount) external;
    function getUnderlyingAsset() external returns(address);
    function stakeUnderlying(uint256 numTokens) external returns(bool);
    function stakeUnderlying(address recipient, uint256 numTokens) external returns (bool);
    function transferOwnership(address newOwner) external;
    function volumeFor(address wallet) external view returns (uint256);
 
}

contract MARLO is ReentrancyGuard, IMARLO {

 	using Address for address;
	using SafeMath for uint8;
	using SafeMath for uint256;

	// Token Details
	string constant _name = "MARLO";
	string constant _symbol = "MARLO";
	uint8 constant _decimals = 18;
	uint256 constant precision = 10**18;

	// Start Supply
	uint256 _supplySELF = 10 * 10**_decimals;

	// Underlying Asset
	address public _tokenPEG = 0x254246331cacbC0b2ea12bEF6632E4C6075f60e2;

	// Balances
	mapping (address => uint256) _userBalance;
	mapping (address => mapping (address => uint256)) _userAllowance;
	mapping (address => uint256) _volumeFor;

	// Fees
	uint256 public _mintFee   = 98000;
	uint256 public _burnFee   = 98000;
	uint256 public _marketFee = 99500;
	uint256 public constant feeDivisor = 10**5;

	// Marketing Data
	address _marketReceiver;
	bool allowMarketing;

	// Fee Exemptions
	mapping (address => bool) isFeeExempt;

	// Owner
	address _owner;

	// Activation
	bool _activated;

    // BNB
    address BNB = 0xB8c77482e45F1F44dE1745F52C74426C631bDD52;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only Owner Function");
        _;
    }

	// Get The Party Started!!
	constructor () {

		// Set Owner
		_owner = msg.sender;

		// Set Marketing
		_marketReceiver = 0xe8ff2d1dF7b511Ac89C616b37e8dd6502da50A23;

		// Fee Exemptions
        isFeeExempt[msg.sender] = true;
        isFeeExempt[_marketReceiver] = true;

		// Send 1 MARLO to DEAD, Ensure Never 0 _supplySELF
        address dead = 0x000000000000000000000000000000000000dEaD;
        _userBalance[address(this)] = (_supplySELF - 1);
        _userBalance[dead] = 1;

	    // Emit Inital Allocations
    	emit Transfer(address(0), address(this), (_supplySELF - 1));
    	emit Transfer(address(0), dead, 1);

	}

	// --------------------------- Function Overrides

	function totalSupply() external view override returns (uint256) {
		return _supplySELF;
	}
	
	function balanceOf(address account) public view override returns (uint256) {
		return _userBalance[account];
	}

	function allowance(address account, address spender) external view override returns (uint256) {
		return _userAllowance[account][spender];
	}

    function name() public pure override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _userAllowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _userAllowance[sender][msg.sender] = _userAllowance[sender][msg.sender].sub(amount, "Insufficient Allowance");
        return _transferFrom(sender, recipient, amount);
    }
    
	// --------------------------- Read Functions

	// Reports Price To ALL Decimals
    function priceFull() external view returns (uint256) {
        return _calcCurrentPrice();
    }

	// Reports Price To 3 Decimals
    function priceShort() external view returns (uint256) {
        return _calcCurrentPrice().mul(10**3).div(precision);
    }

	// Repoorts Underlting Asset
    function getUnderlyingAsset() external override view returns (address) {
        return _tokenPEG;
    }

	// Get Owner
	function getOwner() external override view returns (address) {
		return _owner;
	}

	// --------------------------- Internal Functions

	// Internal Transfer
	function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

		// Standard Checks
		require(sender != address(0) && recipient != address(0), "Transfer Cannot Involve Zero Address");
		require(amount > 0, "Transfer Amount Must Be Greater Than Zero");

		// Grab Current Price
		uint256 _nowPrice = _calcCurrentPrice();

		// Subract From Sender Balance
		_userBalance[sender] = _userBalance[sender].sub(amount, "Insufficient Balance");

		// Give To Recipient
		_userBalance[recipient] = _userBalance[recipient].add(amount);

		// Record Volume
		_volumeFor[sender] += amount;
		_volumeFor[recipient] += amount;

		// Emit Transfer
		emit Transfer(sender, recipient, amount);

		// Emit Current Price/Supply
		emit NowPrice(_nowPrice, _supplySELF);
		        
		return true;

	}		

	// Calculate Current Price Of 1 MARLO Token
	function _calcCurrentPrice() internal view returns (uint256) {
		uint256 _supplyPEG = IBEP20(_tokenPEG).balanceOf(address(this));
		return (_supplyPEG.mul(precision)).div(_supplySELF);
	}

	// Garbage Collection
    function takeOutGarbage() external nonReentrant {
        _checkGarbageCollector();
    }

	function _checkGarbageCollector() internal {
        uint256 bal = _userBalance[address(this)];
        if (bal > 10) {
            // Track Change In Price
            uint256 prePrice = _calcCurrentPrice();
            // burn amount
            _burn(address(this), bal);
            // Emit Collection
            emit GarbageCollected(bal);
            // Emit Price Difference
            emit ChangePrice(prePrice, _calcCurrentPrice(), _supplySELF);
        }
    }

	// Payable
    receive() external payable {
        _checkGarbageCollector();
        _printMoney(msg.sender);
    }

	// --------------------------- Interacting Functions

	// Donate Holdings To Burn
	function donateTokensToBurn(uint256 tokens) external nonReentrant {
		
		// Checks
		require(tokens > 0, "Cannot Burn Zero");
		require(_userBalance[msg.sender] >= tokens, "Insufficient Balance");

		// Grab Current Price
		uint256 _prePrice = _calcCurrentPrice();

		// Burn Tokens
		_burn(msg.sender, tokens);

		// Emit Price Change
		emit ChangePrice(_prePrice, _calcCurrentPrice(), _supplySELF);

		// Emit Burn
		emit BurnedTokens(msg.sender, tokens);

	}

	// Exchange MARLO, Get Underlying Asset To Same Wallet
	function sell(uint256 numTokens) external override nonReentrant {
		_sell(numTokens, msg.sender);
	}

	// Exchange MARLO, Get Underlying Asset To Different Wallet
	function sell(uint256 numTokens, address recipient) external nonReentrant {
		_sell(numTokens, recipient);
	}

	// Sell ALL MARLO, Get Underlying Asset To Same Wallet
    function sellAll() external nonReentrant {
        _sell(_userBalance[msg.sender], msg.sender);
    }

	// Stake Underlying Asset, Get MARLO To Same Wallet : Needs Approval
	function stakeUnderlying(uint256 numTokens) external override nonReentrant returns (bool) {
		return _stakeUnderlying(numTokens, msg.sender);
	}

	// Stake Underlying Asset, Get MARLO To Different Wallet : Needs Approval
	function stakeUnderlying(address recipient, uint256 numTokens) external override nonReentrant returns (bool) {
		return _stakeUnderlying(numTokens, recipient);
	}

	// Reports User Volume
    function volumeFor(address wallet) external override view returns (uint256) {
        return _volumeFor[wallet];
    }

	// Holdings Value Pre-Fee
	function getValueOfHoldings(address holder) public view returns(uint256) {
        return _userBalance[holder].mul(_calcCurrentPrice()).div(precision);
    }

	// --------------------------- Buy/Stake/Mint Functions

	// Purchase MARLO Tokens
	function _printMoney(address recipient) private nonReentrant returns (bool) {
		
        // Check Activation
		require(_activated || _owner == msg.sender, "Token Not Activated");

		// Get Pre-Transaction Price
        uint256 prePrice = _calcCurrentPrice();

		// Get Pre-Transfer Peg Balance
		uint256 prePegBalance = IBEP20(_tokenPEG).balanceOf(address(this));

        // Get Underlying Asset
        bool success = _buyPeg(msg.value);

        // Check For Transfer Success
        require(success, "Failure On Peg Purchase");

		// Post-Transfer Peg Balance
		uint256 newPegBalance = IBEP20(_tokenPEG).balanceOf(address(this));

		// Number of Peg Tokens Received Back
		uint256 grossPegTokens = newPegBalance.sub(prePegBalance);

		// If First Purchase, Use New Amount
		prePegBalance = prePegBalance == 0 ? newPegBalance : prePegBalance;

        // Emit Purchase
        emit TokenPurchased(grossPegTokens, recipient);

        // Prepare Minting
		return _mintPrep(recipient, grossPegTokens, prePegBalance, prePrice);

	}

	// Buy Underlying
	function _buyPeg(uint256 amount) internal returns (bool) {

		address recipient = _tokenPEG;
		bool success = IBEP20(BNB).transfer(recipient, amount);
        return success;

	}

	// Stake Underlying Asset
	function _stakeUnderlying(uint numTokens, address recipient) internal returns (bool) {
		
		// Check Activation
		require(_activated || _owner == msg.sender, "Token Not Activated");
	
		// Check User Balance
		uint256 userPegBalance = IBEP20(_tokenPEG).balanceOf(msg.sender);
	
		// Ensure User Can Complete Request
		require(userPegBalance > 0 && numTokens <= userPegBalance, "Insufficient Balance");
	
		// Get Pre-Transaction Price
		uint256 prePrice = _calcCurrentPrice();
	
		// Get Pre-Transfer Peg Balance
		uint256 prePegBalance = IBEP20(_tokenPEG).balanceOf(address(this));
	
		// Move Peg From User To MARLO Contract
		bool success = IBEP20(_tokenPEG).transferFrom(msg.sender, address(this), numTokens);
		
		// Post-Transfer Peg Balance
		uint256 newPegBalance = IBEP20(_tokenPEG).balanceOf(address(this));
	
		// Number of Peg Tokens User Staked
		uint256 stakedTokens = newPegBalance.sub(prePegBalance);
		
		// Check Nothing Unexpected Happened
		require(stakedTokens <= numTokens && stakedTokens > 0, "Token Evaluation Failure");
		
		// Check Transfer Success
		require(success, "Transfer Failure");

		// If First Purchase, Use New Amount
		prePegBalance = prePegBalance == 0 ? newPegBalance : prePegBalance;

		// Emit Staked
		emit TokensStaked(stakedTokens, recipient);

		// Prepare Minting
		return _mintPrep(recipient, stakedTokens, prePegBalance, prePrice);

	}

	// Mint Preparation
	function _mintPrep(address recipient, uint256 numTokens, uint256 prePegBalance, uint256 prePrice) private returns (bool) {

		// Determine Tokens To Mint Based On Current Price
		uint256 tokensToMint = _supplySELF.mul(numTokens).div(prePegBalance);

		// Fee Exempt
		bool takeFee = !isFeeExempt[msg.sender];

        // Apply Fees
        if (takeFee) {

            // Get Mint Fee
            uint256 netMintFee = tokensToMint.mul((feeDivisor.sub(_mintFee)).div(feeDivisor));

            if (allowMarketing) {

                // Get Market Fee
                uint256 netMarketFee = tokensToMint.mul((feeDivisor.sub(_marketFee)).div(feeDivisor)) ;  

                // Mint To Marketing
                _mint(_marketReceiver, netMarketFee);

                // Net Tokens To Mint
                tokensToMint = tokensToMint.sub(netMintFee.add(netMarketFee));

            } else {

                // Net Tokens To Mint
                tokensToMint = tokensToMint.sub(netMintFee);

            }

        }

		// Mint Tokens To Buyer
		_mint(recipient,tokensToMint);

		// New Price
		uint256 _nowPrice = _calcCurrentPrice();

		// Require New Price >= Pre Price
		require(_nowPrice >= prePrice, "Price Went Down!");

		// Emit Price Change
		emit ChangePrice(prePrice, _nowPrice, _supplySELF);

		// Finish
		return true;

	}

	// The Money Printer
	function _mint(address recipient, uint256 tokensToMint) private {

		// Mint To Buyer
		_userBalance[recipient] = _userBalance[recipient].add(tokensToMint);

		// Adjust Supply
		_supplySELF = _supplySELF.add(tokensToMint);

		// Adjust Volume
		_volumeFor[recipient] += tokensToMint;

		// Emit Transfer
		emit Transfer(address(this), recipient, tokensToMint);

	}

	// --------------------------- Sell/Unstake/Burn Functions

    // Sells MARLO and Sends Back Underlying Asset
    function _sell(uint256 numTokens, address recipient) internal {

		// Ensure User Can Complete Request
        require(numTokens > 0 && _userBalance[msg.sender] >= numTokens, "Unable To Complete Request");

		// Get Gross Tokens Sold
		uint256 grossSoldTokens = numTokens;

		// Get Pre-Transaction Price
		uint256 prePrice = _calcCurrentPrice();

		// Fee Exempt
		bool takeFee = !isFeeExempt[msg.sender];

        // Apply Fees
        if (takeFee) {

            // Get Burn Fee
            uint256 netBurnFee = numTokens.mul((feeDivisor.sub(_burnFee)).div(feeDivisor));

            if (allowMarketing && msg.sender != _marketReceiver) {

                // Get Market Fee
                uint256 netMarketFee = numTokens.mul((feeDivisor.sub(_marketFee)).div(feeDivisor))   ;

                // Mint To Marketing
                _mint(_marketReceiver, netMarketFee);

                // Net Tokens To Burn
                numTokens = numTokens.sub(netBurnFee.add(netMarketFee));

            } else {

                // Net Tokens To Burn
                numTokens = numTokens.sub(netBurnFee);

            }

        }

    // Get Amount Of Underlying Asset To Send Back
    uint256 amountPegToUser = (numTokens.mul(prePrice)).div(precision);

    // Require Underlying Amount > 0
    require(amountPegToUser > 0, "Nothing To Redeem For Given Value");

		// Burn Sold Tokens
		_burn(msg.sender, grossSoldTokens);

		// Send Underlying To Seller
		bool success = IBEP20(_tokenPEG).transfer(recipient, amountPegToUser);

        // Ensure Tokens were Delivered
        require(success, "Underlying Asset Transfer Failure");

		// New Price
		uint256 _nowPrice = _calcCurrentPrice();

		// Require New Price >= Pre Price
		require(_nowPrice >= prePrice, "Price Went Down!");

		// Emit Sell
		emit TokenSold(grossSoldTokens, amountPegToUser, recipient);

		// Emit Price Change
		emit ChangePrice(prePrice, _nowPrice, _supplySELF);

    }

    // Burn Sold/Garbage Tokens
    function _burn(address receiver, uint256 amount) private {
    
        // Burn Uer Tokens
        _userBalance[receiver] = _userBalance[receiver].sub(amount, "Insufficient Balance");
    
        // Adjust Supply
        _supplySELF = _supplySELF.sub(amount, "Negative Supply");
    
		// Adjust Volume
		_volumeFor[receiver] += amount;

		// Emit Transfer
		emit Transfer(receiver, address(0), amount);

    }

	// --------------------------- Owner Functions

	// Activate Token Trading
    function ActivateToken() external onlyOwner {
        require(!_activated, "Already Activated Token");
        _activated = true;
        allowMarketing = true;
        emit TokenActivated();
    }

    // Transfer Ownership To Another User
    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != _owner, "No Change Would Be Made");
        _owner = newOwner;
        emit TransferOwnership(newOwner);
    }
    
    // Transfer Ownership To 0 Address
    function renounceOwnership() external onlyOwner {
        _owner = address(0);
        emit TransferOwnership(address(0));
    }

	// Update Marketing Receiver
    function updateMarketAddress(address newMarket) external onlyOwner {
        require(newMarket != _marketReceiver, "No Change Would Be Made");
        _marketReceiver	= newMarket;
        emit UpdatedMarketAddress(newMarket);
    }

	// Switch Marketing On/Off
	function updateAllowMarketing(bool _allowMarketing) external onlyOwner {
        require(_allowMarketing != allowMarketing, "No Change Would Be Made");
		allowMarketing = _allowMarketing;
		emit AllowMarketingSwitch(_allowMarketing);
	}

	// Exclude From Fees
    function setFeeExemption(address Contract, bool exempt) external onlyOwner {
        require(Contract != address(0));
        isFeeExempt[Contract] = exempt;
        emit SetFeeExemption(Contract, exempt);
    }

    //Set Mint Fee
    function setMintFee(uint256 newMintFee) external onlyOwner {
        require(newMintFee != _mintFee, "No Change Would Be Made");
        require(newMintFee >= 90000 && newMintFee <= 100000, "New Fee Out Of Range");
        uint256 oldFee = _mintFee;
        _mintFee = newMintFee;
        emit MintFeeChange(oldFee, newMintFee);
    }

    //Set Burn Fee
    function setBurnFee(uint256 newBurnFee) external onlyOwner {
        require(newBurnFee != _burnFee, "No Change Would Be Made");
        require(newBurnFee >= 90000 && newBurnFee <= 100000, "New Fee Out Of Range");
        uint256 oldFee = _burnFee;
        _burnFee = newBurnFee;
        emit BurnFeeChange(oldFee, newBurnFee);
    }

    //Set Market Fee
    function setMarketFee(uint256 newMarketFee) external onlyOwner {
        require(newMarketFee != _marketFee, "No Change Would Be Made");
        require(newMarketFee >= 90000 && newMarketFee <= 100000, "New Fee Out Of Range");
        uint256 oldFee = _marketFee;
        _marketFee = newMarketFee;
        emit MarketFeeChange(oldFee, newMarketFee);
    }

	// --------------------------- Emit Functions

    event MarketFeeChange(uint256 oldFee, uint256 newFee);
    event BurnFeeChange(uint256 oldFee, uint256 newFee);
    event MintFeeChange(uint256 oldFee, uint256 newFee);
	event TokenPurchased(uint256 assetsReceived, address recipient);
	event TokensStaked(uint256 stakedTokens, address recipient);
	event BurnedTokens(address who, uint256 amountTokensErased);
	event TokenSold(uint256 soldTokens, uint256 assetsRedeemed, address recipient);
	event NowPrice(uint256 nowPrice, uint256 supplySelf);
	event ChangePrice(uint prePrice, uint256 nowPrice, uint256 supplySelf);
	event GarbageCollected(uint256 amountTokensErased);
	event UpdatedMarketAddress(address newMarket);
	event AllowMarketingSwitch(bool allowMarketing);
	event SetFeeExemption(address Contract, bool exempt);
	event TokenActivated();
	event TransferOwnership(address newOwner);

}