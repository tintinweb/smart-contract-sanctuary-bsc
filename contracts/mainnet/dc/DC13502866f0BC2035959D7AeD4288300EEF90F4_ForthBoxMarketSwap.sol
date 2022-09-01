/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;

    function tokenOfOwner(address owner) external view returns (uint256[] memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function getPropertiesByTokenIds(uint256[] calldata tokenIdArr ) external view returns(uint256[] memory);
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
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }
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
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}
interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes calldata data) external;
    function safeBatchTransferFrom(address from,address to,uint256[] calldata ids,uint256[] calldata amounts,bytes calldata data) external;
    function uri(uint256 id) external view returns (string memory);
}

contract ForthBoxMarketSwap is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    string private _name = "test ForthBox Market Swap";//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    string private _symbol = "test Market Swap ";//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    enum enumSwapType{
        ePlanSell,
        ePlanBuy,
        eSell,
        eBuy,
        eCancle,
        eFix
    }
    enum enumContractType{
        eErc721,
        eErc1155
    }
    enum enumStateType{
        eOpen,
        eClosed,
        eCancled
    }
    struct sContractData {
        enumContractType contractType;
        address contractAddr;
        uint256 token_id;//nft id or ec11155 id
        uint256 amount;
        address erc20Addr;
        uint256 price;
    }

    struct sSwapData {
        uint256 id;
        enumSwapType swapType;
        enumStateType stateType;
        address startAddr;
        sContractData contractData;
        address endAddr;
        uint256 swapId;
        uint256 time;
    }
    mapping(uint256 => sSwapData) private _mSwapData;
    uint256 private _mSumCount = 0;

    mapping(address => mapping(address =>  mapping(uint256 => uint256))) private _mTokenSellInfos;//address contractAddress tokenId amount
    mapping(address => mapping(address =>  uint256)) private _mTokenBuyInfos;//address Erc20ContractAddress amount
    mapping(address => uint256[]) private _mAddressOdrers;

    struct sProjectFee {
        uint256 mFeeRate;
        address mFeeAddress;
        uint256 mSumProjectFee;
        uint256 mSumFundFee;
    }
    uint256 public mFeeRate = 50;//‰  /1000
    uint256 public mSumAllFee = 0;
    uint256 public mSumFundFee = 0;
    address public mFundAdress = 0x03EF9129284815650529E2b3aDeE04CB20947fb9;
    mapping(address => sProjectFee) private _mProjectFees;
    address mManager;

    bool mbStart = true;
    bool mbStartPlanBuy = true;

    mapping (address => bool) private _Is_WhiteContractArr;
    address[] private _WhiteContractArr;

    constructor() {
    }

    //view
    function name() external view returns (string memory) {
        return _name;
    }
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    function totalSupply() public view returns (uint256) {
        return _mSumCount;
    }
    function checkID(uint256 id) public view returns (bool){
        bool isOk = false;
        if(_mSwapData[id].swapType == enumSwapType.ePlanBuy){
            isOk = _checkPlanBuy(id);
        }
        if(_mSwapData[id].swapType == enumSwapType.ePlanSell){
            isOk = _checkPlanSell(id);
        }
        return isOk;
    }
    function checkIDs(uint256[] calldata ids) external view returns (bool[] memory){
        bool[] memory isOks = new bool[](uint256(ids.length));
        for(uint256 i=0; i<isOks.length; ++i) {
            isOks[i] = checkID(ids[i]);
        }
        return isOks;
    }

    function swapInfo(uint256 id) external view returns (sSwapData memory){
        sSwapData memory infos = _mSwapData[id];
        return infos;
    }
    function swapInfos(uint256[] calldata ids) external view returns (sSwapData[] memory){
        sSwapData[] memory infos = new sSwapData[](uint256(ids.length));
        for(uint256 i=0; i<ids.length; ++i) {
            infos[i] =  _mSwapData[ids[i]];
        }
        return infos;
    }

    function userOrderNum(address addr) external view returns (uint256){
        return _mAddressOdrers[addr].length;
    }
    function userOrderIds(address addr,uint256 fromIth,uint256 toIth) external view returns (uint256[] memory){
        require(toIth <= _mAddressOdrers[addr].length-1, "ForthBoxBuyCoin: exist num!");
        require(fromIth <= toIth, "ForthBoxBuyCoin: exist num!");
        uint256[] memory idArr = new uint256[](toIth-fromIth+1);
        uint256 i=0;
        for(uint256 ith = fromIth; ith <= toIth; ith++) {
            idArr[i] = _mAddressOdrers[addr][ith];
            i = i+1;
        }
        return idArr;
    }
    function tokenPlanSellInfo(address userAddr,address contractAddress,uint256 tokenId) public view returns (uint256) {
        return _mTokenSellInfos[userAddr][contractAddress][tokenId];
    }
    function tokenPlanBuyInfos(address userAddr,address contractAddress) public view returns (uint256) {
        return _mTokenBuyInfos[userAddr][contractAddress];
    }
    function isWhiteContract(address account) public view returns (bool) {
        if(_Is_WhiteContractArr[account])return true;
        if(account.isContract()) return false;
        if(tx.origin == msg.sender) return true;
        return false;
    }
    function getProjectFee(address contractAddr) public view returns (uint256 feeRate,uint256 sumProjectFee,uint256 sumFundFee,address feeAddress) {
        feeRate = _mProjectFees[contractAddr].mFeeRate;
        sumProjectFee = _mProjectFees[contractAddr].mSumProjectFee;
        sumFundFee = _mProjectFees[contractAddr].mSumFundFee;
        feeAddress = _mProjectFees[contractAddr].mFeeAddress;
        return (feeRate,sumProjectFee,sumFundFee,feeAddress);
    }

    // write
    event event_newOrder(uint256 indexed id);
    function _planSell(uint256 contractTypeInt,address contractAddr,uint256 token_id,uint256 amount,address erc20Addr,uint256 price) internal{
        enumContractType contractType = enumContractType(contractTypeInt);
        address startAddr = _msgSender();
        if(contractType == enumContractType.eErc721){
            IERC721 token721 = IERC721(contractAddr);
            require(startAddr == token721.ownerOf(token_id),"ForthBoxMarketSwap: Only the owner of this Token could sell It!");
            require(token721.isApprovedForAll(startAddr,address(this)),"ForthBoxMarketSwap: must ApprovedForAll !");
            require(amount == 1,"ForthBoxMarketSwap: amount must 1 !");

            require(_mTokenSellInfos[startAddr][contractAddr][token_id] == 0,"ForthBoxMarketSwap: already in sell !");
        }
        if(contractType == enumContractType.eErc1155){
            IERC1155 token1155 = IERC1155(contractAddr);

            require(amount > 0,"ForthBoxMarketSwap: amount too small !");
            require(token1155.isApprovedForAll(startAddr,address(this)),"ForthBoxMarketSwap: must ApprovedForAll !");
            require(token1155.balanceOf(startAddr, token_id)>=_mTokenSellInfos[startAddr][contractAddr][token_id].add(amount),"ForthBoxMarketSwap: already in sell !");
        }
        {//Erc20
            IERC20 erc20 = IERC20(erc20Addr);
            require(erc20.balanceOf(startAddr) >= 0,"ForthBoxMarketSwap: wrong erc20 Address!");
        }

        require(price > 10000,"ForthBoxMarketSwap: price too small !");
        {
            _mSwapData[_mSumCount].id = _mSumCount;
            _mSwapData[_mSumCount].swapType = enumSwapType.ePlanSell;
            _mSwapData[_mSumCount].stateType = enumStateType.eOpen;
            _mSwapData[_mSumCount].startAddr = startAddr;

            _mSwapData[_mSumCount].contractData.contractType = contractType;
            _mSwapData[_mSumCount].contractData.contractAddr = contractAddr;
            _mSwapData[_mSumCount].contractData.token_id = token_id;
            _mSwapData[_mSumCount].contractData.amount = amount;
            _mSwapData[_mSumCount].contractData.erc20Addr = erc20Addr;
            _mSwapData[_mSumCount].contractData.price = price;

            _mSwapData[_mSumCount].swapId = _mSwapData[_mSumCount].id;
            _mSwapData[_mSumCount].time = block.timestamp;
        }
        _mAddressOdrers[startAddr].push(_mSumCount);
        _mSumCount = _mSumCount.add(1);

        _mTokenSellInfos[startAddr][contractAddr][token_id] = _mTokenSellInfos[startAddr][contractAddr][token_id].add(amount);

        emit event_newOrder(_mSumCount-1);
    }
    function _checkPlanSell(uint256 id) internal view returns (bool){
        bool isOk = true;
        enumContractType contractType = _mSwapData[id].contractData.contractType;
        
        address contractAddr = _mSwapData[id].contractData.contractAddr;
        uint256 token_id = _mSwapData[id].contractData.token_id;
        uint256 amount = _mSwapData[id].contractData.amount;

        address startAddr = _mSwapData[id].startAddr;

        isOk = isOk && (_mSwapData[id].swapType == enumSwapType.ePlanSell);
        isOk = isOk && (_mSwapData[id].stateType == enumStateType.eOpen);

        if(contractType == enumContractType.eErc721){
            IERC721 token721 = IERC721(contractAddr);
            isOk = isOk && (startAddr == token721.ownerOf(token_id));
            isOk = isOk && (token721.isApprovedForAll(startAddr,address(this)));
        }
        if(contractType == enumContractType.eErc1155){
            IERC1155 token1155 = IERC1155(contractAddr);
            isOk = isOk && (amount > 0);
            isOk = isOk && (token1155.balanceOf(startAddr, token_id)>=_mTokenSellInfos[startAddr][contractAddr][token_id]);
            isOk = isOk && (token1155.isApprovedForAll(startAddr,address(this)));
        }
        return isOk;
    }

    function _planBuy(uint256 contractTypeInt,address contractAddr,uint256 token_id,uint256 amount,address erc20Addr,uint256 price) internal{
        enumContractType contractType = enumContractType(contractTypeInt);
        address startAddr = _msgSender();
        if(contractType == enumContractType.eErc721){
            IERC721 token721 = IERC721(contractAddr);

            require(amount == 1,"ForthBoxMarketSwap: amount must 1 !");
            require(token721.balanceOf(startAddr)>=0,"ForthBoxMarketSwap: wrong erc721 address !");
        }
        if(contractType == enumContractType.eErc1155){
            IERC1155 token1155 = IERC1155(contractAddr);

            require(amount > 0,"ForthBoxMarketSwap: amount too small !");
            require(token1155.balanceOf(startAddr,token_id)>=0,"ForthBoxMarketSwap: wrong erc1155 address !");
        }
        {//Erc20
            IERC20 erc20 = IERC20(erc20Addr);
            require(erc20.balanceOf(startAddr) >= price.add(_mTokenBuyInfos[startAddr][erc20Addr]) ,"ForthBoxMarketSwap: not have enough erc20 token!");
            require(erc20.allowance(startAddr,address(this)) >= price.add(_mTokenBuyInfos[startAddr][erc20Addr]),"ForthBoxMarketSwap: not allowance enough erc20 token!");
        }

        require(price > 10000,"ForthBoxMarketSwap: price too small !");

        {
            _mSwapData[_mSumCount].id = _mSumCount;
            _mSwapData[_mSumCount].swapType = enumSwapType.ePlanBuy;
            _mSwapData[_mSumCount].stateType = enumStateType.eOpen;
            _mSwapData[_mSumCount].startAddr = startAddr;

            _mSwapData[_mSumCount].contractData.contractType = contractType;
            _mSwapData[_mSumCount].contractData.contractAddr = contractAddr;
            _mSwapData[_mSumCount].contractData.token_id = token_id;
            _mSwapData[_mSumCount].contractData.amount = amount;
            _mSwapData[_mSumCount].contractData.erc20Addr = erc20Addr;
            _mSwapData[_mSumCount].contractData.price = price;

            _mSwapData[_mSumCount].swapId = _mSwapData[_mSumCount].id;
            _mSwapData[_mSumCount].time = block.timestamp;
        }
        _mAddressOdrers[startAddr].push(_mSumCount);
        _mSumCount = _mSumCount.add(1);

        _mTokenBuyInfos[startAddr][erc20Addr] = _mTokenBuyInfos[startAddr][erc20Addr].add(price);

        emit event_newOrder(_mSumCount-1);
    }
    function _checkPlanBuy(uint256 id) internal view returns (bool){
        bool isOk = true;
        address erc20Addr = _mSwapData[id].contractData.erc20Addr;
        address startAddr = _mSwapData[id].startAddr;

        isOk = isOk && (_mSwapData[id].swapType == enumSwapType.ePlanBuy);
        isOk = isOk && (_mSwapData[id].stateType == enumStateType.eOpen);

        IERC20 erc20 = IERC20(erc20Addr);
        isOk = isOk && (erc20.balanceOf(startAddr) >= _mTokenBuyInfos[startAddr][erc20Addr]);
        isOk = isOk && (erc20.allowance(startAddr,address(this)) >= _mTokenBuyInfos[startAddr][erc20Addr]);
        return isOk;
    }
    function _tranERC20(address erc20Addr,address contractAddr,address fromAddr,address toAddr,uint256 amount) internal{
        IERC20 erc20 = IERC20(erc20Addr);
        if(mFeeRate>0 && _mProjectFees[contractAddr].mFeeRate>0){
            uint256 fundFee = amount.mul(mFeeRate).div(1000);
            uint256 projectFee = amount.mul(_mProjectFees[contractAddr].mFeeRate).div(1000);
            uint256 amountLast = amount.sub(fundFee).sub(projectFee);
            erc20.safeTransferFrom(fromAddr, toAddr, amountLast);
            erc20.safeTransferFrom(fromAddr, mFundAdress, fundFee);
            erc20.safeTransferFrom(fromAddr, _mProjectFees[contractAddr].mFeeAddress, projectFee);

            mSumFundFee += fundFee;
            mSumAllFee += fundFee + projectFee;
            _mProjectFees[contractAddr].mSumFundFee += fundFee;
            _mProjectFees[contractAddr].mSumProjectFee += projectFee;
        }
        else
        {
            if(mFeeRate>0){
                uint256 fundFee = amount.mul(mFeeRate).div(1000);
                uint256 amountLast = amount.sub(fundFee);
                erc20.safeTransferFrom(fromAddr, toAddr, amountLast);
                erc20.safeTransferFrom(fromAddr, mFundAdress, fundFee);
                _mProjectFees[contractAddr].mSumFundFee += fundFee;
                mSumFundFee += fundFee;
                mSumAllFee += fundFee;
            }
            else{
                erc20.safeTransferFrom(fromAddr, toAddr, amount);
            }
        }

    }
    function _tranERC721_ERC1155(enumContractType contractType,address contractAddr,address fromAddr,address toAddr,
        uint256 token_id,uint256 amount) internal{

        if(contractType == enumContractType.eErc721){
            IERC721 token721 = IERC721(contractAddr);
            token721.safeTransferFrom(fromAddr,toAddr,  token_id);
            require(toAddr == token721.ownerOf(token_id),"ForthBoxMarketSwap: Transfer nft wrong!");
        }
        if(contractType == enumContractType.eErc1155){
            IERC1155 token1155 = IERC1155(contractAddr);
            uint256 numOri = token1155.balanceOf(toAddr, token_id);
            token1155.safeTransferFrom(fromAddr,toAddr, token_id,amount,"");  
            require(token1155.balanceOf(toAddr, token_id)>=amount + numOri,"ForthBoxMarketSwap: transfer erc1155 wrong !");
        }
    }
    function _buy(uint256 id) internal{
        require(id<_mSumCount,"ForthBoxMarketSwap:id too big!");
        require(_checkPlanSell(id),"ForthBoxMarketSwap: plan sell order not  right!");

        enumContractType contractType = _mSwapData[id].contractData.contractType;       
        address contractAddr = _mSwapData[id].contractData.contractAddr;
        uint256 token_id = _mSwapData[id].contractData.token_id;
        uint256 amount = _mSwapData[id].contractData.amount;
        address erc20Addr = _mSwapData[id].contractData.erc20Addr;
        uint256 price = _mSwapData[id].contractData.price;

        address startAddr = _mSwapData[id].startAddr;
        address endAddr = _msgSender();
        {
            _mSwapData[_mSumCount].id = _mSumCount;
            _mSwapData[_mSumCount].swapType = enumSwapType.eBuy;
            _mSwapData[_mSumCount].stateType = enumStateType.eClosed;
            _mSwapData[_mSumCount].startAddr = startAddr;

            _mSwapData[_mSumCount].contractData = _mSwapData[id].contractData;

            _mSwapData[_mSumCount].endAddr = endAddr;
            _mSwapData[_mSumCount].swapId = id;
            _mSwapData[_mSumCount].time = block.timestamp;
        }
        _mAddressOdrers[endAddr].push(_mSumCount);
        _mSumCount = _mSumCount.add(1);

        _mSwapData[id].stateType = enumStateType.eClosed;

        _mTokenSellInfos[startAddr][contractAddr][token_id] = _mTokenSellInfos[startAddr][contractAddr][token_id].sub(amount);

        _tranERC20(erc20Addr,contractAddr,endAddr,startAddr,price);
        _tranERC721_ERC1155(contractType,contractAddr,startAddr,endAddr, token_id,amount);

        emit event_newOrder(_mSumCount-1);
    }

    function _sell(uint256 id,uint256 token_id_sell) internal{
        require(id<_mSumCount,"ForthBoxMarketSwap:id too big!");
        require(_checkPlanBuy(id),"ForthBoxMarketSwap: plan buy order not  right!");

        enumContractType contractType = _mSwapData[id].contractData.contractType;       
        address contractAddr = _mSwapData[id].contractData.contractAddr;
        uint256 token_id = _mSwapData[id].contractData.token_id;
        if(contractType == enumContractType.eErc721){
            token_id = token_id_sell;
        }
        uint256 amount = _mSwapData[id].contractData.amount;
        address erc20Addr = _mSwapData[id].contractData.erc20Addr;
        uint256 price = _mSwapData[id].contractData.price;

        address startAddr = _mSwapData[id].startAddr;
        address endAddr = _msgSender();
        {
            _mSwapData[_mSumCount].id = _mSumCount;
            _mSwapData[_mSumCount].swapType = enumSwapType.eBuy;
            _mSwapData[_mSumCount].stateType = enumStateType.eClosed;
            _mSwapData[_mSumCount].startAddr = startAddr;

            _mSwapData[_mSumCount].contractData = _mSwapData[id].contractData;

            _mSwapData[_mSumCount].endAddr = endAddr;
            _mSwapData[_mSumCount].swapId = id;
            _mSwapData[_mSumCount].time = block.timestamp;
        }

        _mSwapData[id].stateType = enumStateType.eClosed;
        _mTokenBuyInfos[startAddr][erc20Addr] = _mTokenBuyInfos[startAddr][erc20Addr].sub(price);

        _tranERC721_ERC1155(contractType,contractAddr,endAddr,startAddr, token_id,amount);
        _tranERC20(erc20Addr,contractAddr,startAddr,endAddr,price);

        _mAddressOdrers[endAddr].push(_mSumCount);

        _mSumCount = _mSumCount.add(1);

        emit event_newOrder(_mSumCount-1);
    }
    function _cancle(uint256 id) internal{
        require(id<_mSumCount,"ForthBoxMarketSwap:id too big!");

        address contractAddr = _mSwapData[id].contractData.contractAddr;
        uint256 token_id = _mSwapData[id].contractData.token_id;
        uint256 amount = _mSwapData[id].contractData.amount;
        address erc20Addr = _mSwapData[id].contractData.erc20Addr;
        uint256 price = _mSwapData[id].contractData.price;

        address startAddr = _mSwapData[id].startAddr;
        address endAddr = _msgSender();

        require(_mSwapData[id].stateType == enumStateType.eOpen,"ForthBoxMarketSwap:not open!");
        if(_mSwapData[id].swapType != enumSwapType.ePlanSell){
            require(_mSwapData[id].swapType != enumSwapType.ePlanBuy,"ForthBoxMarketSwap:not plan buy or plan sell!");
        }
        require(startAddr == _msgSender(),"ForthBoxMarketSwap:not owner!");
        {
            _mSwapData[_mSumCount].id = _mSumCount;
            _mSwapData[_mSumCount].swapType = enumSwapType.eCancle;
            _mSwapData[_mSumCount].stateType = enumStateType.eCancled;
            _mSwapData[_mSumCount].startAddr = startAddr;

            _mSwapData[_mSumCount].contractData = _mSwapData[id].contractData;

            _mSwapData[_mSumCount].endAddr = endAddr;
            _mSwapData[_mSumCount].swapId = id;
            _mSwapData[_mSumCount].time = block.timestamp;
        }
        
        _mSwapData[id].stateType = enumStateType.eCancled;
        _mAddressOdrers[endAddr].push(_mSumCount);

        if(_mSwapData[id].swapType == enumSwapType.ePlanBuy){
            _mTokenBuyInfos[startAddr][erc20Addr] = _mTokenBuyInfos[startAddr][erc20Addr].sub(price);
        }
        if(_mSwapData[id].swapType == enumSwapType.ePlanSell){
            _mTokenSellInfos[startAddr][contractAddr][token_id] = _mTokenSellInfos[startAddr][contractAddr][token_id].sub(amount);
        }
       
        _mSumCount = _mSumCount.add(1);

        emit event_newOrder(_mSumCount-1);
    }
    function _fix(uint256 id,uint256 price) internal{
        require(id<_mSumCount,"ForthBoxMarketSwap:id too big!");
        address erc20Addr = _mSwapData[id].contractData.erc20Addr;
        uint256 priceOld =_mSwapData[id].contractData.price;
        address startAddr = _mSwapData[id].startAddr;
        address endAddr = _msgSender();

        require(_mSwapData[id].stateType == enumStateType.eOpen,"ForthBoxMarketSwap:not open!");
        if(_mSwapData[id].swapType != enumSwapType.ePlanSell){
            require(_mSwapData[id].swapType != enumSwapType.ePlanBuy,"ForthBoxMarketSwap:not plan buy or plan sell!");
        }
        require(startAddr == _msgSender(),"ForthBoxMarketSwap:not owner!");
        {
            _mSwapData[_mSumCount].id = _mSumCount;
            _mSwapData[_mSumCount].swapType = enumSwapType.eFix;
            _mSwapData[_mSumCount].stateType = enumStateType.eClosed;
            _mSwapData[_mSumCount].startAddr = startAddr;

            _mSwapData[_mSumCount].contractData = _mSwapData[id].contractData;
            _mSwapData[_mSumCount].contractData.price = price;

            _mSwapData[_mSumCount].endAddr = endAddr;
            _mSwapData[_mSumCount].swapId = id;
            _mSwapData[_mSumCount].time = block.timestamp;
        }
        _mAddressOdrers[endAddr].push(_mSumCount);
        _mSwapData[id].contractData.price = price;

        if(_mSwapData[id].swapType == enumSwapType.ePlanBuy){
            _mTokenBuyInfos[startAddr][erc20Addr] = _mTokenBuyInfos[startAddr][erc20Addr].add(price).sub(priceOld);
            require(_checkPlanBuy(id),"ForthBoxMarketSwap: plan buy order not  right!");
        }
        if(_mSwapData[id].swapType == enumSwapType.ePlanSell){
            require(_checkPlanSell(id),"ForthBoxMarketSwap: plan sell order not  right!");
        }
       
        _mSumCount = _mSumCount.add(1);
        emit event_newOrder(_mSumCount-1);
    }
    function planSell(uint256 contractTypeInt,address contractAddr,uint256 token_id,uint256 amount,address erc20Addr,uint256 price) external nonReentrant {
        require(mbStart, "ForthBoxMarketSwap: not start!");
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");
        _planSell(contractTypeInt,contractAddr,token_id,amount,erc20Addr,price);
    }
    function planBuy(uint256 contractTypeInt,address contractAddr,uint256 token_id,uint256 amount,address erc20Addr,uint256 price)  external nonReentrant{
        require(mbStart, "ForthBoxMarketSwap: not start!");
        require(mbStartPlanBuy, "ForthBoxMarketSwap: not  plan buy!");
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");
        _planBuy(contractTypeInt,contractAddr,token_id,amount,erc20Addr,price);
    }

    function buy(uint256 id) external nonReentrant{
        require(mbStart, "ForthBoxMarketSwap: not start!");
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");
        _buy(id);   
    }
    function sell(uint256 id,uint256 token_id_sell) external nonReentrant{
        require(mbStart, "ForthBoxMarketSwap: not start!");
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");
        _sell(id,token_id_sell);   
    }
    function fix(uint256 id,uint256 price) external nonReentrant{
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");
        _fix(id,price);   
    }
    function cancle(uint256 id) external nonReentrant{
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");
        _cancle(id);   
    }
    function planSells(uint256 contractTypeInt,address contractAddr,uint256[] calldata token_ids,uint256[] calldata amounts,address erc20Addr,uint256[] calldata prices) external nonReentrant {
        require(mbStart, "ForthBoxMarketSwap: not start!");
        require(token_ids.length == amounts.length , "ForthBoxMarketSwap: length not equal!");
        require(token_ids.length == prices.length , "ForthBoxMarketSwap: length not equal!");
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");

        for(uint256 i=0; i<token_ids.length; ++i) {
            _planSell(contractTypeInt,contractAddr,token_ids[i],amounts[i],erc20Addr,prices[i]);
        }
    }
    function planBuys(uint256 contractTypeInt,address contractAddr,uint256[] calldata token_ids,uint256[] calldata amounts,address erc20Addr,uint256[] calldata prices)  external nonReentrant{
        require(mbStart, "ForthBoxMarketSwap: not start!");
        require(mbStartPlanBuy, "ForthBoxMarketSwap: not  plan buy!");
        require(token_ids.length == amounts.length , "ForthBoxMarketSwap: length not equal!");
        require(token_ids.length == prices.length , "ForthBoxMarketSwap: length not equal!");
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");

        for(uint256 i=0; i<token_ids.length; ++i) {
            _planBuy(contractTypeInt,contractAddr,token_ids[i],amounts[i],erc20Addr,prices[i]);
        }
    }

    function buys(uint256[] calldata ids) external nonReentrant{
        require(mbStart, "ForthBoxMarketSwap: not start!");
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");
        for(uint256 i=0; i<ids.length; ++i) {
            _buy(ids[i]);   
        }

    }
    function sells(uint256[] calldata ids,uint256[] calldata token_id_sells) external nonReentrant{
        require(mbStart, "ForthBoxMarketSwap: not start!");
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");
        require(ids.length == token_id_sells.length , "ForthBoxMarketSwap: length not equal!");
        for(uint256 i=0; i<ids.length; ++i) {
            _sell(ids[i],token_id_sells[i]);   
        } 
    }
    function cancles(uint256[] calldata ids) external nonReentrant{
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");
        for(uint256 i=0; i<ids.length; ++i) {
            _cancle(ids[i]);   
        }   
    }
    function fixs(uint256[] calldata ids,uint256[] calldata prices) external nonReentrant{
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");
        for(uint256 i=0; i<ids.length; ++i) {
            _fix(ids[i],prices[i]);    
        }
    }
    //---write onlyOwner---//
    function changeBatchOperation(bool bStart,bool bStartPlanBuy) external onlyOwner{
        mbStart = bStart;
        mbStartPlanBuy = bStartPlanBuy;
    }
    function changeFee(address tFundAdress,uint256 feeRate) external onlyOwner{
        require(feeRate<=200, "ForthBoxMarketSwap: feeRate too big!");
        mFundAdress = tFundAdress;
        mFeeRate = feeRate;
    }
    function changeManager(address tManager) external onlyOwner{
        mManager = tManager;
    }


    function setProjectFee(address contractAddr,uint256 feeRate,address feeAddress) external{
        require(isWhiteContract(_msgSender()), "ForthBoxMarketSwap: Contract not in white list!");
        require(feeRate<=200, "ForthBoxMarketSwap: feeRate too big!");
        if(owner() != _msgSender()){
            require(mManager == _msgSender(), "ForthBoxSellToken: not manager!");
        }
        _mProjectFees[contractAddr].mFeeRate = feeRate;
        _mProjectFees[contractAddr].mFeeAddress = feeAddress;
    }

    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "ForthBoxMarketSwap:Account is already White list");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "ForthBoxMarketSwap:Account is already out White list");
        for (uint256 i = 0; i < _WhiteContractArr.length; i++){
            if (_WhiteContractArr[i] == account){
                _WhiteContractArr[i] = _WhiteContractArr[_WhiteContractArr.length - 1];
                _WhiteContractArr.pop();
                _Is_WhiteContractArr[account] = false;
                break;
            }
        }
    }



}