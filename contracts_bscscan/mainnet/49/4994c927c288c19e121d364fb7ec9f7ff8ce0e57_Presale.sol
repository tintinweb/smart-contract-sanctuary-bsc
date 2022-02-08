/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.6;
 
interface IBEP20 {
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
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

library SafeERC20 {
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

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IPancakeRouter01 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}


contract Presale is Ownable {
    
    using SafeERC20 for IBEP20;

    IBEP20 public utilityToken;
    IBEP20 constant public USDT = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IBEP20 constant public WBNB = IBEP20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IPancakeRouter01 constant public PSCRouter = IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant public WBNB_USDT = 0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE;
    
    mapping(uint256 => mapping(address => uint256)) private received;
    mapping(uint256 => mapping(bytes32 => bool)) private isUsed;
    mapping(uint256 => uint256) public funds;
    mapping(address => bool) private whitelistedTokens;

    uint256 public tokenCount;

    struct ILOAirdropStruct {
        uint256 _tokenID;
        address _utilityToken;
        uint256 _airdropAmount;
        uint256 _totalAirdrop;
        uint256 _presaleAmount;
        uint256 _ILOAmount;
        uint256 _presalePrice;
        uint256 _ILOPrice;
        uint256 _remainAirdrop;
        uint256 _remainPresale;
        uint256 _remainILO;
        uint256 _dec;
    }

    event TokenWhitelisted(
        address indexed tokenAddress,
        bool whitelisted
    );

    mapping(uint256 => ILOAirdropStruct) public airdropStructs;

    function setTokenInfo(uint256 _tokenId, address _utilityToken, uint256 _airdropAmount, uint256 _totalAirdrop, uint256 _presaleAmount, uint256 _ILOAmount, uint256 _presalePrice, uint256 _ILOPrice) external onlyOwner {
        tokenCount = tokenCount ++;
        airdropStructs[_tokenId] = ILOAirdropStruct(_tokenId, _utilityToken, _airdropAmount, _totalAirdrop,
            _presaleAmount, _ILOAmount, _presalePrice, _ILOPrice, _totalAirdrop, _presaleAmount, _ILOAmount, IBEP20(_utilityToken).decimals());
    }
    
    function getBNBPrice() public view returns (uint256) {
        return USDT.balanceOf(WBNB_USDT) / WBNB.balanceOf(WBNB_USDT);
    }

    function getTokenPrice(address _token, uint256 _amount) public view returns (uint256[] memory) {
        require(_token != address(0), "swapping with zero address");
        address[] memory path;
        path[0] = _token;
        path[1] = address(WBNB);
        path[2] = address(USDT);
        return PSCRouter.getAmountsOut(_amount, path);
    }

    function whitelistTokens(address[] memory _tokenAddresses, bool[] memory _value)
    public onlyOwner {
        require(_tokenAddresses.length==_value.length, "length not matching");
        for(uint256 i = 0; i < _tokenAddresses.length; i++ ){
            whitelistedTokens[_tokenAddresses[i]] = _value[i];
            emit TokenWhitelisted(_tokenAddresses[i], _value[i]);
        }
    }

    function changeIloPrice(uint256 _tokenId, uint256 _newPrice) public onlyOwner{
        airdropStructs[_tokenId]._ILOPrice = _newPrice;
    }

    function changePresalePrice(uint256 _tokenId, uint256 _newPrice) public onlyOwner{
        airdropStructs[_tokenId]._presalePrice = _newPrice;
    }

    function closePresale(uint256 _tokenId) public onlyOwner{
        airdropStructs[_tokenId]._remainPresale = 0;
        airdropStructs[_tokenId]._presaleAmount = 0;
    }

    function closeIlo(uint256 _tokenId) public onlyOwner{
        airdropStructs[_tokenId]._remainILO = 0;
        airdropStructs[_tokenId]._ILOAmount = 0;
    }

    function changeTokenInfo(
        uint256 _tokenId, 
        address _utilityToken, 
        uint256 _airdropAmount, 
        uint256 _totalAirdrop, 
        uint256 _presaleAmount, 
        uint256 _ILOAmount, 
        uint256 _presalePrice, 
        uint256 _ILOPrice
    ) public onlyOwner {
        airdropStructs[_tokenId]._utilityToken = _utilityToken;

        airdropStructs[_tokenId]._totalAirdrop = _totalAirdrop;

        if(_ILOAmount > airdropStructs[_tokenId]._ILOAmount){
            airdropStructs[_tokenId]._remainILO = airdropStructs[_tokenId]._remainILO + (_ILOAmount - airdropStructs[_tokenId]._ILOAmount);
        }else{
            airdropStructs[_tokenId]._remainILO  = airdropStructs[_tokenId]._remainILO - (airdropStructs[_tokenId]._ILOAmount - _ILOAmount > airdropStructs[_tokenId]._remainILO ? airdropStructs[_tokenId]._remainILO : airdropStructs[_tokenId]._ILOAmount - _ILOAmount);
        }

        if(_presaleAmount > airdropStructs[_tokenId]._presaleAmount){
            airdropStructs[_tokenId]._remainPresale = airdropStructs[_tokenId]._remainPresale + (_presaleAmount - airdropStructs[_tokenId]._presaleAmount);
        }else{
            airdropStructs[_tokenId]._remainPresale = airdropStructs[_tokenId]._remainPresale - (airdropStructs[_tokenId]._presaleAmount - _presaleAmount > airdropStructs[_tokenId]._remainPresale ? airdropStructs[_tokenId]._remainPresale : airdropStructs[_tokenId]._presaleAmount - _presaleAmount);
        }

        airdropStructs[_tokenId]._presaleAmount = _presaleAmount;
        airdropStructs[_tokenId]._airdropAmount = _airdropAmount;
        airdropStructs[_tokenId]._ILOAmount = _ILOAmount;
        airdropStructs[_tokenId]._presalePrice = _presalePrice;
        airdropStructs[_tokenId]._ILOPrice = _ILOPrice;
        airdropStructs[_tokenId]._dec = IBEP20(_utilityToken).decimals();
    }
    
    function presaleBNB(uint256 _tokenId) payable external {
        uint256 bnbPrice = getBNBPrice();
        uint256 tokenAmount = (bnbPrice * airdropStructs[_tokenId]._presalePrice * msg.value * airdropStructs[_tokenId]._dec) / 10**18;
        funds[_tokenId] += bnbPrice * msg.value;
        require(airdropStructs[_tokenId]._remainPresale >= tokenAmount, "Presale: insufficient token funds");
        IBEP20(airdropStructs[_tokenId]._utilityToken).safeTransfer(_msgSender(), tokenAmount);
        airdropStructs[_tokenId]._remainPresale = airdropStructs[_tokenId]._remainPresale - tokenAmount;
    }
    
    function presaleUsdt(uint256 _tokenId, uint256 _amount) external {
        uint256 tkDec = airdropStructs[_tokenId]._dec;
        uint256 tokenAmount = (_amount * airdropStructs[_tokenId]._presalePrice / 10**18) * 10**tkDec;
        require(airdropStructs[_tokenId]._remainPresale >= tokenAmount, "Presale: insufficient token funds");
        funds[_tokenId] += _amount;
        USDT.safeTransferFrom(_msgSender(), address(this), _amount);
        IBEP20(airdropStructs[_tokenId]._utilityToken).safeTransfer(_msgSender(), tokenAmount);
        airdropStructs[_tokenId]._remainPresale = airdropStructs[_tokenId]._remainPresale - tokenAmount;
    }

    function presaleToken(uint256 _tokenId, uint256 _amount, address _token) external {
        require(whitelistedTokens[_token], "token not usable");

        uint256 tokenAmount = (getTokenPrice(_token, _amount)[1] * airdropStructs[_tokenId]._presalePrice * 10**airdropStructs[_tokenId]._dec) / 10**IBEP20(_token).decimals();
        
        require(airdropStructs[_tokenId]._remainPresale >= tokenAmount, "Presale: insufficient token funds");
        
        IBEP20(_token).safeTransferFrom(_msgSender(), address(this), _amount);
        IBEP20(airdropStructs[_tokenId]._utilityToken).safeTransfer(_msgSender(), tokenAmount);
        airdropStructs[_tokenId]._remainPresale = airdropStructs[_tokenId]._remainPresale - tokenAmount;
    }

    function ILOBNB(uint256 _tokenId) payable external {
        require(airdropStructs[_tokenId]._remainPresale == 0, "presale: not finished presale");
        
        uint256 bnbPrice = getBNBPrice();
        uint256 tokenAmount = (bnbPrice * airdropStructs[_tokenId]._ILOPrice * msg.value / 10**18) * airdropStructs[_tokenId]._dec;
        funds[_tokenId] += bnbPrice * msg.value;
        
        require(airdropStructs[_tokenId]._remainILO >= tokenAmount, "Presale: insufficient token funds");
        
        IBEP20(airdropStructs[_tokenId]._utilityToken).safeTransfer(_msgSender(), tokenAmount);
        airdropStructs[_tokenId]._remainILO = airdropStructs[_tokenId]._remainILO - tokenAmount;
    }
    
    function ILOUsdt(uint256 _tokenId, uint256 _amount) external {
        require(airdropStructs[_tokenId]._remainPresale == 0, "presale: not finished presale");

        uint256 tokenAmount = (_amount * airdropStructs[_tokenId]._ILOPrice * 10**airdropStructs[_tokenId]._dec) / 10**18;
        
        require(airdropStructs[_tokenId]._remainILO >= tokenAmount, "Presale: insufficient token funds");
        
        funds[_tokenId] += _amount;
        USDT.safeTransferFrom(_msgSender(), address(this), _amount);
        IBEP20(airdropStructs[_tokenId]._utilityToken).safeTransfer(_msgSender(), tokenAmount);
        airdropStructs[_tokenId]._remainILO = airdropStructs[_tokenId]._remainILO - tokenAmount;
    }

    function IloToken(uint256 _tokenId, uint256 _amount, address _token) external {
        require(whitelistedTokens[_token], "token not usable");

        uint256 tokenAmount = (getTokenPrice(_token, _amount)[1] * airdropStructs[_tokenId]._ILOPrice * 10**airdropStructs[_tokenId]._dec) / 10**IBEP20(_token).decimals();
        
        require(airdropStructs[_tokenId]._remainILO >= tokenAmount, "Presale: insufficient token funds");
        
        IBEP20(_token).safeTransferFrom(_msgSender(), address(this), _amount);
        IBEP20(airdropStructs[_tokenId]._utilityToken).safeTransfer(_msgSender(), tokenAmount);
        airdropStructs[_tokenId]._remainILO = airdropStructs[_tokenId]._remainILO - tokenAmount;
    }

    function getAirdrop(uint256 _tokenId, bytes32 _signedMessage, uint8 _v, bytes32 _r, bytes32 _s) external {
        require(received[_tokenId][_msgSender()] != _tokenId, "Presale: already received");
        require(isUsed[_tokenId][keccak256(abi.encodePacked(_v,_r,_s))] != true, "Presale: invalid user");
        require(owner() == ecrecover(_signedMessage, _v, _r, _s), 'Presale: invalid signer');
        require(airdropStructs[_tokenId]._remainAirdrop >= airdropStructs[_tokenId]._airdropAmount, "Presale: insufficient funds");

        isUsed[_tokenId][keccak256(abi.encodePacked(_v,_r,_s))] = true;
        received[_tokenId][_msgSender()] = _tokenId;
        airdropStructs[_tokenId]._remainAirdrop = airdropStructs[_tokenId]._remainAirdrop - airdropStructs[_tokenId]._airdropAmount;
        IBEP20(airdropStructs[_tokenId]._utilityToken).safeTransfer(_msgSender(), airdropStructs[_tokenId]._airdropAmount);
    }

    // This following functions are used on this contract, and are not part of the airdrop or presale
    function withdrawToken(address _token, uint256 _amount, address _to) external onlyOwner {
        IBEP20(_token).safeTransfer(_to, _amount);
    }

    function withdrawBNB(address payable _addr, uint256 _amount) external onlyOwner {
        //audit point 6
        Address.sendValue(_addr,_amount);
    }

}