/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

pragma solidity 0.8.7;
// SPDX-License-Identifier: Unlicensed

contract Ownable {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }
	
    constructor() {
        _owner = msg.sender;
    }
	
    function owner() public view virtual returns (address) {
        return _owner;
    }
	
    function transferOwnership(address newOwner) public onlyOwner {
	   require(newOwner != address(0));
	   emit OwnershipTransferred(_owner, newOwner);
	   _owner = newOwner;
    }
}

contract Pausable is Ownable {
	event Pause();
	event Unpause();

	bool public paused = false;
  
	modifier whenNotPaused() {
		require(!paused, "Contract is paused right now");
		_;
	}
  
	modifier whenPaused() {
		require(paused, "Contract is not paused right now");
		_;
	}
  
	function pause() onlyOwner whenNotPaused public {
		paused = true;
		emit Pause();
	}
	
	function unpause() onlyOwner whenPaused public {
		paused = false;
		emit Unpause();
	}
}

interface IBEP20 {
    function transfer(address _to, uint _amount) external view returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
	function allowance(address owner, address spender) external view returns (uint256);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
	
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
  
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
   
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
	
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeBEP20 {
    using Address for address;
	
    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
	
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract $xCrowdSale is Ownable, Pausable {

    using SafeBEP20 for IBEP20;
    IBEP20 public tokenAddress = IBEP20(0x3A4BB779942f22Dcbb4B9Eb09f7f63779F45675b);
	IBEP20 public acceptedCurrency = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
	uint256 public pricePerToken;
	uint256 public minInvestment;
    uint256 public tokenSold;
	
	event TokenPurchase(address indexed purchaser, uint256 amount);
    constructor(){}
	
	function buyTokens(uint256 amount) external whenNotPaused{
		require(amount >= minInvestment, "Min Investment Required");
		
		uint256 tokens = convertAmountToTokens(amount);
		
		require(tokenAddress.balanceOf(address(this)) >= tokens, "Insufficient Token Balance For Sale");
		require(acceptedCurrency.allowance(msg.sender, address(this)) >= amount, "Insufficient Allowance For Buy");
		
		acceptedCurrency.safeTransferFrom(msg.sender, owner(), amount);
		tokenAddress.safeTransfer(msg.sender, tokens);
		
		emit TokenPurchase(msg.sender, tokens);
		tokenSold = tokenSold + tokens;
	}
	
	function convertAmountToTokens(uint256 amount) public view returns (uint256) {
	    uint256 tokens = amount * 10**18 / pricePerToken;
	    return tokens;
	}
	
	function updateTokenPrice(uint256 tokenNewPrice) external onlyOwner {
        pricePerToken = tokenNewPrice;
    }
	
	function updateMinInvestment(uint256 newMinInvestment) external onlyOwner {
        require(newMinInvestment >= 0, "Incorrect value");
		minInvestment = newMinInvestment;
    }
	
	function updateTokenAddress(IBEP20 newToken) external onlyOwner {
		tokenAddress = IBEP20(newToken);
    }
	
    function availableForSale() external view returns (uint256){
        return tokenAddress.balanceOf(address(this));
    }
}