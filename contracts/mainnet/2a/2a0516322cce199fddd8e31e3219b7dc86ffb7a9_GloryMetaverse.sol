/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value : amount}("");
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

        (bool success, bytes memory returndata) = target.call{value : value}(data);
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

pragma solidity ^0.8.0;
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
    unchecked {
        uint256 oldAllowance = token.allowance(address(this), spender);
        require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
        uint256 newAllowance = oldAllowance - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

pragma solidity ^0.8.0;
//pragma experimental ABIEncoderV2;

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

    function add(uint256 a, uint256 b) internal pure returns (uint256) { return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
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


contract GloryMetaverse is Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

 ///////////////////////////////// constant /////////////////////////////////
    // todo: wethToken address
    address constant WETH_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address FUND_ADDRESS = 0xFf8c81162b3878C83aA7fb209a9037CDD715dB8b;
    address MARKET_ADDRESS = 0x2627963b190D1Aa64C50CA5FF539215b44B1fca3;
    address TOKEN_ADDRESS;

    //config
    mapping(uint => uint) public _inviteRate;
    mapping(uint => uint) public _stage;
    mapping(uint => bool) public _stageState;
    mapping(uint => uint) public _nftTerm;
    mapping(uint => uint) public _nftNum;
    mapping(uint => bool) public _nftState;
    mapping(uint => bool) public _oderState;
    mapping(uint => bool) public oderIdOf;
    mapping(uint => bool) public payIdOf;
    address public ownerSigner;
    uint public minAmount = 100000000000000000;
    uint public _decimals = 100;
    mapping(address => mapping(uint => uint)) public _OwnerNftNum;

    event TransferNFT(address indexed user, uint _amount, uint _oderId);

    constructor (address tokenAddr,address _ownerSigner) {
        _stage[1] = 100000;
        _stage[2] = 90000;
        _stage[3] = 80000;
        _stage[4] = 70000;
        _inviteRate[1] = 25;
        _inviteRate[2] = 15;
        _inviteRate[3] = 10;
        _inviteRate[4] = 10;
        _stageState[1] = true;
        _nftTerm[1] = 400000 ether;
        _nftTerm[2] = 250000 ether;
        _nftTerm[3] = 200000 ether;
        _nftNum[1] = 900;
        _nftNum[2] = 1200;
        _nftNum[3] = 1500;
        _nftState[1] = true;
        TOKEN_ADDRESS = tokenAddr;
        ownerSigner = _ownerSigner;
    }

    function setStage(uint _index,uint _value) external onlyOwner {
        _stage[_index] = _value;
    }

    function setStageState(uint _index,bool _value) external onlyOwner {
        _stageState[_index] = _value;
    }

    function setMinAmount(uint _value) external onlyOwner {
        minAmount = _value;
    }

    function setFundAddress(address _Addr) external onlyOwner {
        FUND_ADDRESS = _Addr;
    }

    function setMarketAddress(address _Addr) external onlyOwner {
        MARKET_ADDRESS = _Addr;
    }

    function setTokenAddress(address _Addr) external onlyOwner {
        TOKEN_ADDRESS = _Addr;
    }

    function getTokenAddress() public view returns (address) {
        return TOKEN_ADDRESS;
    }

    function setNftTerm(uint _index,uint _value) external onlyOwner {
        _nftTerm[_index] = _value;
    }
    
    function setNftNum(uint _index,uint _value) external onlyOwner {
        _nftNum[_index] = _value;
    }

    function setNftState(uint _index,bool _value) external onlyOwner {
        _nftState[_index] = _value;
    }

    function extractExtra(address _constantAddress, address _account,uint _amount) external onlyOwner {
        if(_constantAddress == WETH_ADDRESS){
            payable(_account).transfer(_amount);
        }else{
            IERC20(_constantAddress).safeTransfer(_account, _amount);
        }
        
    }


    function Oxfm2t198b97(address _inviteAddr1,address _inviteAddr2,address _inviteAddr3,uint _type) external payable {
        require(!(minAmount > msg.value), "minAmount: minAmount > msg.value");
        require(_stageState[_type], "Not yet open");
        uint _amount = msg.value;
        uint payAmount = _amount;
        payAmount = inviteAllocation(payAmount,_amount,_inviteAddr1,1,_type);
        payAmount = inviteAllocation(payAmount,_amount,_inviteAddr2,2,_type);
        payAmount = inviteAllocation(payAmount,_amount,_inviteAddr3,3,_type);
        payAmount = inviteAllocation(payAmount,_amount,FUND_ADDRESS,4,_type);

        payable(MARKET_ADDRESS).transfer(payAmount);
        uint _tokenAmount = _amount.mul(_stage[_type]);
        IERC20(TOKEN_ADDRESS).safeTransfer(msg.sender, _tokenAmount);

    }

    function inviteAllocation(uint payAmount, uint _amount, address _inviteAddr, uint _inviteNum, uint _type)internal returns (uint) {
        uint _inviteAddrAmount = _amount.mul(_inviteRate[_inviteNum]).div(_decimals);
        payAmount = payAmount.sub(_inviteAddrAmount);
        payable(_inviteAddr).transfer(_inviteAddrAmount);
        if(_inviteNum == 4){
            return payAmount;
        }
        uint _tokenAmount = _inviteAddrAmount.mul(_stage[_type]);
        IERC20(TOKEN_ADDRESS).safeTransfer(_inviteAddr, _tokenAmount);

        return payAmount;
    }


    function mintNFT(uint _type, uint _oder)external{
        require(_nftState[_type], "Not yet open");
        require(!_oderState[_oder], "mintNFT: invalid _oderId");
        IERC20(TOKEN_ADDRESS).safeTransferFrom(msg.sender, address(this), _nftTerm[_type]);
        _OwnerNftNum[msg.sender][_type]++;
        _nftNum[_type]--;
        _oderState[_oder] = true;
    }

    function transferNFT(uint _payId,uint _oderId, address _to, uint _amount, uint8 _v, bytes32 _r, bytes32 _s) external payable {
        require(!oderIdOf[_oderId], "transferNFT: invalid _oderId");
        require(!payIdOf[_payId], "transferNFT: invalid _payId");
        require(address(0) != ownerSigner, "transferNFT: address(0) != ownerSigner");
        uint payAmount = msg.value;
        require(payAmount == _amount, "transferNFT: payAmount == _amount");
        bytes32 msgHash = keccak256(abi.encodePacked(_oderId, _to, _amount));
        require(ecrecover(msgHash, _v, _r, _s) == ownerSigner, "transferNFT: incorrect signer");

        payable(_to).transfer(payAmount);
        oderIdOf[_oderId] = true;
        payIdOf[_payId] = true;

        emit TransferNFT(_to,_amount, _oderId);
    }


    receive() external payable {}

  

}