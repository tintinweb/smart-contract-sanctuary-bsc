/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface BSCFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface BSCBnb {
    function balanceOf(address owner) external view returns (uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract Context {
    constructor() internal {}
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

  
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
       
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

   
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

   
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

   
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        
        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}



contract RISEROCEKTIDO is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    IERC20 public token;
    uint256 private start;
    
    uint256 public tokenPerBNB;
    bool isStarted = true;
    uint256 public bnbRaised;
    
    int public totalInvestments = 0;
    uint256 public totalTOKENDistributed = 0;
    uint256 public maxBNBSupply = 6500000000000000000000;
    
    struct Investors{
        address _name;
        uint256 _tokenStored;
        uint256 _bnbInvested;
    }
    
    mapping (address => Investors) public investors;
    address[] public totalInvestors;
    uint256[] public salesData;

    uint256 public minInvestment = 100000000000000000;
    uint256 public maxInvestment = 100000000000000000000;
    uint256 dividend = 10000000000000;

    event Returned(uint256 _invested, uint256 _tokenDistributed);

    constructor (
        uint256 _tokenPerBNB,
        address _token
    ) public {
        token = IERC20(_token);
        tokenPerBNB = _tokenPerBNB;
    }

    
    function priceTOKEN (uint256 _price) private onlyOwner {
        tokenPerBNB = _price;
    }

    function investBNB(address _investor) public payable returns(bool status){
        require(isStarted, 'IMO is not yet started!');
        require(_investor != address(0), 'Wut? A Zero Address Investor');
        require(msg.value >= minInvestment && msg.value <= maxInvestment, 'TOKEN Not Sold In This Amount! Please check minimum and maximum investment');
        require(maxBNBSupply > bnbRaised , 'Oops ! Sale is Over now');

        
        if(investors[_investor]._name != address(0)){ // Checking for validations
            uint256 _totalBNBGiven = investors[msg.sender]._bnbInvested;
            uint256 _investedBNB = _totalBNBGiven.add(msg.value);
            require(_investedBNB <= maxInvestment, 'Whoa! Thats a lot of investment from you! :)');
        }

        uint256 amountInvested = msg.value; // Total Invested Amount
        bool _status = false; // Initialize returning status
       
         uint256 tokenDistributed = amountInvested.mul(tokenPerBNB).div(dividend); // TOKEN Calculated
 
        assert(status = true); // No errors, status set to `True`
        emit Returned(amountInvested, tokenDistributed);

        Investors memory invest = investors[_investor];
        if(invest._name == address(0)){ // Checking previous investments
            investors[_investor] = Investors(
                _investor,
                tokenDistributed,
                msg.value
                
            );
            totalInvestors.push(_investor);
        }else{
            investors[_investor]._bnbInvested += amountInvested; // Adding BNB Investment
            investors[_investor]._tokenStored += tokenDistributed; // Adding distribution to previous stored data
        }
        bnbRaised += amountInvested; // BNB Raised
        totalTOKENDistributed += tokenDistributed; 
        totalInvestments ++; // Total Investments increment
        salesData.push(tokenDistributed); // Sales data for last token sold
        address payable _owner = payable(address(uint160(owner())));
        token.transferFrom(_owner, msg.sender, tokenDistributed);
        _owner.transfer(address(this).balance);
        return _status;
    }

    function setDividend(uint256 _dividend) public onlyOwner{
        dividend = _dividend;
    }

    
    function getMaxTOKEN() public view returns(uint256){
        uint256 _maxTOKEN = (maxInvestment.mul(tokenPerBNB));
        return _maxTOKEN;
    }
    
    
    function bnbLiquidity(address payable _reciever, uint256 _amount) public onlyOwner {
        _reciever.transfer(_amount); // Adding BNB Liquidity to TOKEN-BNB pool
    }

    
    function getInvestor(address _addr) public view returns (Investors memory invest) {
        return investors[_addr]; // Investor Details
    }

    function totalInvestor() public view returns (uint){
        return totalInvestors.length; // Total Investors / Token HOLDERS
    }

    function setMaxInvest(uint256 _invest) public onlyOwner {
        maxInvestment = _invest;
    }

    function setMaxBNBInvestment(uint256 _invest) public onlyOwner {
        maxBNBSupply = _invest;
    }

    function setMinInvest(uint256 _invest) public onlyOwner {
        minInvestment = _invest;
    }

    function setperTOKEN(uint256 _amount) public onlyOwner {
        tokenPerBNB = _amount;
    }

    function setStart(bool _start) public onlyOwner returns (uint){
        isStarted = _start;
    }

    function setTokenAddress(IERC20 _tokenset) public onlyOwner {
        require(_tokenset != IERC20(address(0)));
        token = _tokenset;
    }

    function transferAnyERC20Token( address payaddress ,address tokenAddress, uint256 tokens ) public onlyOwner 
    {
        IERC20(tokenAddress).transfer(payaddress, tokens);
    }
}