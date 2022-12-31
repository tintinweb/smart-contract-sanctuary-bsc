/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

interface IBEP20 {
    
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
   
    function isContract(address account) internal view returns (bool) {
        
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

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

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

     function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

abstract contract SafeBEP20 {
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
       

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { 
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Context {
    
    constructor()  {}

    function _msgSender() internal view returns (address ) {
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

    constructor()  {
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

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Pausable is Context {
    
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract IMPERIAL_IEO is Ownable, Pausable, SafeBEP20 {

    IBEP20 public imperialDenar;
    IBEP20 public imperialShares;
    address public treasuryAddress;

    mapping(address => uint256) public isApproved;

    event BuyToken(address indexed Callet, address indexed TokenAddress, uint256 InputAmount, uint256 TokenAmount);
    event Emergency(address indexed Receiver, address indexed TokenAddress, uint256 TokenAmount);
    
    constructor(address _treasury_address) {
        treasuryAddress = _treasury_address;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unPause() external onlyOwner {
        _unpause();
    }

    function buyTokens(address _token_address, uint256 _token_amount) external payable {

        require(isApproved[_token_address] != 0, 'Token not in sale');

        uint256 transferToken;
        if(address(imperialDenar) == _token_address){
            require(_token_amount == 0," token amount must be 0");
            transferToken = msg.value * isApproved[address(imperialDenar)] / 1e18;
            require(payable(treasuryAddress).send(msg.value),"Transaction failed");

        emit BuyToken(msg.sender, _token_address, msg.value, transferToken);

        } else if(address(imperialShares) == _token_address ){
            require(msg.value == 0,"BNB value must be zero");
            safeTransferFrom(imperialDenar, msg.sender, treasuryAddress, _token_amount);
            transferToken = _token_amount * isApproved[address(imperialShares)] / 1e18;

        emit BuyToken(msg.sender, _token_address, _token_amount, transferToken);

        }else {
            revert("invalid token");
        }
        
        safeTransfer(IBEP20(_token_address), msg.sender, transferToken);

    }

    function setImperialDenar(address _imperail_Denar, uint256 _Denar_per_BNB) external onlyOwner {
        imperialDenar = IBEP20(_imperail_Denar);
        isApproved[_imperail_Denar] = _Denar_per_BNB;
    }

    function setImperialSharess(address _imperail_Sharess, uint256 _Shares_per_Denar) external onlyOwner {
        imperialShares = IBEP20(_imperail_Sharess);
        isApproved[_imperail_Sharess] = _Shares_per_Denar;
    }

    function approveTokens(address _token_address, uint256 _approve_amount) external onlyOwner{
        isApproved[_token_address] = _approve_amount;
    }

    function emergency(address _token_address, address _to, uint256 _token_amount) external onlyOwner {
        if(_token_address == address(0x0)){
            require(payable(_to).send(_token_amount),"transaction failed");
        } else {
            IBEP20(_token_address).transfer(_to, _token_amount);
        }

        emit Emergency(_token_address, _to, _token_amount);
    }

}