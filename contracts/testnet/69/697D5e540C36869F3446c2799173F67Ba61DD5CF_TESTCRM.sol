/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {

            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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


abstract contract Ownable is Context {
    address private _owner;
    address private _node_op;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function nodeop() public view virtual returns (address) {
        return _node_op;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    modifier onlyAllowed() {
        require((owner() == _msgSender() || nodeop() == _msgSender()),"Ownable : Caller is not allowed");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    
    function setNodeAddress(address _addr) public onlyOwner {
        require(_addr != address(0), "Ownable: new owner is the zero address");
        _node_op = _addr;
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
    
}
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mintFromContract(address _addr,uint256 amount) external returns (bool);

    function mint(uint256 _amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDOContract {
     struct User {
        address upline;
        uint256 totalPurchase;
        uint256 mainPoolShare;
        uint256 NodeAPoolsShare;
        uint256 NodeBPoolsShare;
        uint256 NodeCPoolsShare;
        uint256 totalSpend;
        uint32 referrals;
        uint32 lastTransTime;
        bool status;
        bool isDev;
        bool isCompleted;
    }

    function users(address _addr) view external returns (User memory);
}

contract TESTCRM is Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    address private ROUTER_ADDR = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address private QQT_ADDR    = 0x20d8961Ee0390754da8EA70b307499d540558111;
    address private QQT_IDO = 0xe0151DB0FF14117B853542dB469b97196ce495E0;
    address private QQC_ADDR = 0xcF54bB57511A3910D7C168505B5D0f6dc370109c;
    address private QQG_ADDR = 0x690850d4124d0C589Eb0Db80e08EBABC4df42c50;
    address private USDT_ADDR = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 private maxEmission = 250000000000000000000000;
    uint256 public currentEmission = 250000000000000000000000;
    uint256 private minForceBurn = 10000000000000000000000;

    bool public isForceBan = true;

    struct User {
        uint256 totalPayout;
        uint256 totalClaimed;
        uint256 totalBurn;
        uint256 totalSpend;
        bool status;
    }

    mapping(address => User) public user;

    constructor() {
        
    }
    
    function initDailyEmission() onlyAllowed external {
        IERC20 token = IERC20(QQT_ADDR);
        token.mint(currentEmission);
    }

    function setNewEmission(uint256 _amount) onlyAllowed external {
        require(_amount <= maxEmission,"Maximum 250K only Emit Everyday ");
        currentEmission = _amount;
    }

    function forceBurn(uint256 _amount) external {
        require(_amount >= minForceBurn,"Minimum Required");
        
        IERC20 token = IERC20(QQT_ADDR);
        
        require(token.allowance(msg.sender,address(this)) >= _amount,"Dont have approval");
        require(token.balanceOf(msg.sender) >= _amount,"Didnt have enough balance");
        require(callIDOUser(msg.sender).status == true,"Registration Required");
        token.safeTransferFrom(msg.sender,deadAddress,_amount);
        addBurn(msg.sender,_amount);
    }

    function callIDOUser(address _addr) view private returns (IDOContract.User memory) {
        IDOContract.User memory _data = IDOContract(QQT_IDO).users(_addr);
        return _data;
    }

    function addBurn(address _addr , uint256 _amount) private {
         user[_addr].totalBurn = user[_addr].totalBurn.add(_amount);

        IERC20 qqc = IERC20(QQC_ADDR);
        IERC20 qqg = IERC20(QQG_ADDR);
        
        qqc.mintFromContract(_addr,_amount); //Mint QQC for Each Main Pool Shares
        qqg.mintFromContract(_addr,_amount); //Mint QQG for Each Main Pool Shares

         emit QQTBurn(_addr,_amount);
    }

    function addEmission(address[] calldata _addr,uint256[] calldata _amount) onlyAllowed external {
            uint8 i=0;
            for(i;i<_addr.length;i++) {
                user[_addr[i]].totalPayout = user[_addr[i]].totalPayout.add(_amount[i]);
            }
    }
    
    function claimEmission(uint256 _amount) external {
        require(user[msg.sender].totalClaimed.add(_amount) <= user[msg.sender].totalPayout,"Not Enough Balance");
        IERC20 token = IERC20(QQT_ADDR);
        
        user[msg.sender].totalClaimed = user[msg.sender].totalClaimed.add(_amount);
        token.safeTransfer(msg.sender,_amount);

        emit QQTClaim(msg.sender,_amount);
    }

    function claimBurnEmission(uint256 _amount) external {
        require(user[msg.sender].totalClaimed.add(_amount) <= user[msg.sender].totalPayout,"Not Enough Balance");
        IERC20 token = IERC20(QQT_ADDR);
        
        require(token.allowance(msg.sender,address(this)) >= _amount ,"Allowance Required");

        user[msg.sender].totalClaimed = user[msg.sender].totalClaimed.add(_amount);
        token.safeTransfer(msg.sender,_amount);
        token.safeTransferFrom(msg.sender,deadAddress,_amount);
        addBurn(msg.sender,_amount);

        emit QQTClaim(msg.sender,_amount);
    }

    function BuyBurnQQT(uint256 _amount) external {
        require(callIDOUser(msg.sender).status == true,"Registration Required");
        IERC20 USD = IERC20(USDT_ADDR);
        IERC20 QQT = IERC20(QQT_ADDR);
        
        require(USD.balanceOf(msg.sender) >= _amount,"NOT ENOUGH Balance");
        require(USD.allowance(msg.sender,address(this)) >= _amount ,"Approval Failed");
        require(QQT.allowance(msg.sender,address(this)) >=0 ,"QQT Approval Failed");
        
        USD.safeTransferFrom(msg.sender,address(this),_amount);
        
        USD.approve(ROUTER_ADDR,_amount);
        
        IRouter _router = IRouter(ROUTER_ADDR);
        
        address[] memory path;
        path = new address[](2);
        path[0] = USDT_ADDR;
        path[1] = QQT_ADDR;
        
        uint256 _temp_pre = QQT.balanceOf(address(this));

        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amount,0,path,address(this),block.timestamp);

        uint256 _new_bal = QQT.balanceOf(address(this));

        uint256 _qqt_received = _new_bal.sub(_temp_pre);

        QQT.safeTransfer(msg.sender,_qqt_received);
        QQT.safeTransferFrom(msg.sender,deadAddress,_qqt_received);
        user[msg.sender].totalSpend = user[msg.sender].totalSpend.add(_amount);
        addBurn(msg.sender,_qqt_received);
        
    }

    function stopForceBan() external onlyOwner {
        isForceBan = false;
    }

    event QQTBurn(address indexed _addr,uint256 _amount);
    event QQTClaim(address indexed _addr , uint256 _amount);
}