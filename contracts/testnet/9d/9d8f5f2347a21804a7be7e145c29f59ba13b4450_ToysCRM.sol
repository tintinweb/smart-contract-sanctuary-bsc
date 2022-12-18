/**
 *Submitted for verification at BscScan.com on 2022-12-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
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

    function burnToken(uint256 _amount) external ;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721 /* is ERC165 */ {
            event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

            event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

            event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


            function balanceOf(address _owner) external view returns (uint256);

            function ownerOf(uint256 _tokenId) external view returns (address);

            function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

            function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

            function approve(address _approved, uint256 _tokenId) external payable;

            function setApprovalForAll(address _operator, bool _approved) external;

            function getApproved(uint256 _tokenId) external view returns (address);

            function isApprovedForAll(address _owner, address _operator) external view returns (bool);
            
            function totalSupply() external view returns (uint256); //return currently Minted Count
        
            function MAX_SBS() external view returns(uint256); //Will return Max supply allowed

            function setMaxSupply(uint256 _max_supply) external;
            
            function mint(uint256 _amount,address _addr) external returns (uint256);

            function passprice(uint256 _tokenId) external returns (uint256);
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}



abstract contract ERC721Recipient is IERC721Receiver {

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _id,
        bytes calldata _data
    ) public virtual override returns (bytes4) {
        // do stuff

        return IERC721Receiver.onERC721Received.selector;
    }
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
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

contract ToysCRM  is ERC721Recipient{

    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address owner;
    address toysNFT = 0xe8CB0422e3b41d960f07Ef016746ADA65f10553B; //ToysWorld NFT Address
    address toysPass = 0x9C3CbeA95693a1Cb307A1971af7953e5A0094C42; //Toysworld Free Pass Address
    address usdtAddress = 0xbBDA9eAF67ae64505AbA789A428666A3E9A9fD1a; //USDT Token Address
    address gemsAddress = 0x079e4691499186e19ec9641778039a125785E86c; //GEMS Token
    address rounter_addres = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //Router Address
    
    address nodeAddress = 0xB7278bF310D50F1f1c0af1E35354f3A5cCCdBC49; //On Chain Node Address
    address company_address = 0x6179360E0cD15424682704e73639d89F855AdF36; //Compay Address

    uint256 totalStakeGems;
    
    struct User {
        uint256 gems;
        uint256 totalPayout;
        uint256 balance;
        uint256 totalBuy;
        uint256 totalSell;
    }

    struct ToysList{
        uint256 currentPrice;
        address currentOwner;
        bool stakeStatus;
        bool isOnSales;
        bool isClose;
    }

    struct PendingBuy {
        uint256 totalAmount;
        bool isNewBuy;
        uint256 roiAmount;
        uint256 nftId;
        address currentOwner;
        uint256 expiryTime;
        bool isSplit;
        uint256 splitPrice;
        uint8 splitCount;
    }

    struct snapDetails {
        uint256 _amount;
        address _addr;
    }


    mapping(uint256 => ToysList) public toysList;
    mapping(address => PendingBuy) public pendingBuyList;
    mapping(address =>User)  public users;
    mapping(uint256 => snapDetails) public snapMapping;
    mapping(address => uint256) public stakeList;

    constructor() {
        owner = msg.sender;
    }

     modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAllowed() {

        require(msg.sender == owner || msg.sender == nodeAddress);
        _;
    }

    function addNodeAddress(address _addr) onlyOwner external {
            require(_addr != address(0));
            nodeAddress = _addr;

    }

    function updateCompanyAddress(address _addr) onlyOwner external {
            require(_addr != address(0));
            company_address = _addr;

    }

    function paySnap(uint256 _transId,uint256 _amount) external {
        require(snapMapping[_transId]._amount == 0,"Snap Already Payed");
        
        IERC20 token = IERC20(gemsAddress);
        
        require(token.allowance(msg.sender,address(this)) >= _amount,"Approval");
        
        token.safeTransferFrom(msg.sender,address(this),_amount);

        snapMapping[_transId]._amount = _amount;

        emit snapPay(msg.sender,_transId,_amount);
    }

    function returnSnap(uint256 _transId , uint256 _repay) onlyAllowed external {
        require(snapMapping[_transId]._amount >= _repay,"Snap Already Payed");
        uint256 _leftover = snapMapping[_transId]._amount.sub(_repay);

         IERC20 token = IERC20(gemsAddress);
         token.safeTransfer(snapMapping[_transId]._addr,_repay);
         token.burnToken(_leftover);

         delete snapMapping[_transId];
    }
 
    function buyGems(uint256 _amount) external {

        IERC20 token = IERC20(usdtAddress);
        
        require(token.allowance(msg.sender,address(this)) >= _amount,"Approval");
        
        token.safeTransferFrom(msg.sender,address(this),_amount);
        token.safeTransfer(company_address,_amount);

        IRouter _router = IRouter(rounter_addres);
        address[] memory path;
        path = new address[](2);
        path[0] = usdtAddress;
        path[1] = gemsAddress;

        uint256[] memory getAmountOut = _router.getAmountsOut(_amount,path);

        IERC20(gemsAddress).transfer(msg.sender,getAmountOut[1]);
        
        //emit buyGemsEvent(msg.sender,_amount);
    }

    function buyWipes(uint256 _amount) external {
        
        IERC20 token = IERC20(gemsAddress);

        IRouter _router = IRouter(rounter_addres);
        address[] memory path;
        path = new address[](2);
        path[0] = gemsAddress;
        path[1] = usdtAddress;

        uint256[] memory getAmountOut = _router.getAmountsOut(_amount,path);

        
        require(token.allowance(msg.sender,address(this)) >= getAmountOut[1],"Approval");
        
        token.safeTransferFrom(msg.sender,address(this),getAmountOut[1]);
        token.burnToken(getAmountOut[1]);

        users[msg.sender].gems = users[msg.sender].gems.add(_amount);

        emit buyWipesEvent(msg.sender,_amount);
    }

    function addBidNew(address[] calldata _addr,uint256[] calldata _amount,uint256 _time) external onlyAllowed {
        
        uint8 i = 0;
        for (i; i < _addr.length; i++) {
            pendingBuyList[_addr[i]].totalAmount = _amount[i];
            pendingBuyList[_addr[i]].isNewBuy = true;
            pendingBuyList[_addr[i]].expiryTime = _time;
        }

    }

    function addBidOld(address[] calldata _addr,uint256[] calldata _nftId,uint256[] calldata _amount,uint256[] calldata _roi,uint256 _time) external onlyAllowed {

        uint8 i = 0;

        for (i; i < _addr.length; i++) {
            require(toysList[_nftId[i]].stakeStatus == true,"Required Stake");
            pendingBuyList[_addr[i]].totalAmount = _amount[i];
            pendingBuyList[_addr[i]].isNewBuy = false;
            pendingBuyList[_addr[i]].roiAmount = _roi[i];
            pendingBuyList[_addr[i]].nftId = _nftId[i];
            pendingBuyList[_addr[i]].currentOwner = toysList[_nftId[i]].currentOwner;
            pendingBuyList[_addr[i]].expiryTime = _time;

            toysList[_nftId[i]].isOnSales = true;
        }
    }

    function addBidSplit(address _addr,uint256 _oldnft,uint256 _total_amount,uint256 _single_price,uint256 _roi,uint8 _split_count,uint256 _time) external onlyAllowed {

        require(toysList[_oldnft].stakeStatus == true,"Required Stake");
        pendingBuyList[_addr].totalAmount = _total_amount;
        pendingBuyList[_addr].isNewBuy = false;
        pendingBuyList[_addr].roiAmount = _roi;
        pendingBuyList[_addr].nftId = _oldnft;
        pendingBuyList[_addr].isSplit = true;
        pendingBuyList[_addr].splitCount = _split_count;
        pendingBuyList[_addr].currentOwner = toysList[_oldnft].currentOwner;
        pendingBuyList[_addr].splitPrice = _single_price;
        pendingBuyList[_addr].expiryTime = _time;
    }

    function stakeNFT(uint256 tokenId) external {
        
        IERC721 nft = IERC721(toysNFT);
        require(nft.isApprovedForAll(msg.sender,address(this)),"Set Approval");
        require(nft.ownerOf(tokenId) == msg.sender,"Not Owner");
        
        nft.safeTransferFrom(msg.sender,address(this),tokenId);
        
        toysList[tokenId].currentOwner = msg.sender;
        toysList[tokenId].stakeStatus = true;
        toysList[tokenId].isOnSales = false;

        emit stakeEvent(msg.sender,tokenId,toysList[tokenId].currentPrice);
    }

    function addPayout(address[] calldata _addr , uint256[] calldata _payout) external onlyAllowed {
        uint8 i=0;
        
        for(i;i<_addr.length;i++) {
            users[_addr[i]].totalPayout = users[_addr[i]].totalPayout.add(_payout[i]);
            users[_addr[i]].balance = users[_addr[i]].balance.add(_payout[i]);
        }
    }

    function claimPayout(uint256 _amount) external {

        require(users[msg.sender].balance >= _amount,"Not Enough");
        
        IERC20 token = IERC20(usdtAddress);
        
        users[msg.sender].balance = users[msg.sender].balance.sub(_amount);
        token.safeTransfer(msg.sender,_amount);
        
        emit claimEvent(msg.sender,_amount);
    }

    function buyFromSales() external {
        require(pendingBuyList[msg.sender].expiryTime >= block.timestamp);
        require(pendingBuyList[msg.sender].isNewBuy == false,"Wrong Buy");
        require(pendingBuyList[msg.sender].isSplit == false,"Only Normal Buy");
        
        IERC20 token = IERC20(usdtAddress);
        IERC721 nft = IERC721(toysNFT);

        uint256 tokenId = pendingBuyList[msg.sender].nftId;

        require(nft.ownerOf(tokenId) == address(this),"NFT Owner Failed");
        require(token.allowance(msg.sender,address(this)) >= pendingBuyList[msg.sender].totalAmount,"Not Approve");
        require(token.balanceOf(msg.sender) >= pendingBuyList[msg.sender].totalAmount,"Balance Not Enough");

        token.safeTransferFrom(msg.sender,address(this),pendingBuyList[msg.sender].totalAmount);

        uint256 sellerReceive = pendingBuyList[msg.sender].totalAmount.sub(pendingBuyList[msg.sender].roiAmount);
        token.safeTransfer(pendingBuyList[msg.sender].currentOwner,sellerReceive);
        nft.transferFrom(address(this),msg.sender,tokenId);

        toysList[tokenId].currentPrice = pendingBuyList[msg.sender].totalAmount;
        toysList[tokenId].currentOwner = msg.sender;
        toysList[tokenId].stakeStatus = false;
        toysList[tokenId].isOnSales = false;

        emit buyBidEvent(msg.sender,tokenId,pendingBuyList[msg.sender].totalAmount);

        delete pendingBuyList[msg.sender];

    }

    function buyFromSplit() external
    {
        require(pendingBuyList[msg.sender].expiryTime >= block.timestamp);
        require(pendingBuyList[msg.sender].isNewBuy == false,"Wrong Buy");
        require(pendingBuyList[msg.sender].isSplit == true,"Only Split Buy");
        
        IERC20 token = IERC20(usdtAddress);
        IERC721 nft = IERC721(toysNFT);

        uint256 tokenId = pendingBuyList[msg.sender].nftId;

        require(nft.ownerOf(tokenId) == address(this),"NFT Owner Failed");
        require(token.allowance(msg.sender,address(this)) >= pendingBuyList[msg.sender].totalAmount,"Not Approve");
        require(token.balanceOf(msg.sender) >= pendingBuyList[msg.sender].totalAmount,"Balance Not Enough");

        token.safeTransferFrom(msg.sender,address(this),pendingBuyList[msg.sender].totalAmount);
        uint256 sellerReceive = pendingBuyList[msg.sender].totalAmount.sub(pendingBuyList[msg.sender].roiAmount);
        token.safeTransfer(pendingBuyList[msg.sender].currentOwner,sellerReceive);
        
        toysList[tokenId].currentPrice = 0;
        toysList[tokenId].currentOwner = address(this);
        toysList[tokenId].stakeStatus = false;
        toysList[tokenId].isOnSales = false;

        uint8 i=0;

        for(i;i< pendingBuyList[msg.sender].splitCount;i++)
        {
             _buyFromMint(pendingBuyList[msg.sender].splitPrice,msg.sender);
        }

        delete pendingBuyList[msg.sender];
    }

    function buyNewToy() external {

        require(pendingBuyList[msg.sender].isNewBuy == true,"New Buy Not Allowed");
        require(pendingBuyList[msg.sender].expiryTime >= block.timestamp);
        
        IERC20 token = IERC20(usdtAddress);

        require(token.allowance(msg.sender,address(this)) >= pendingBuyList[msg.sender].totalAmount,"Not Approve");
        require(token.balanceOf(msg.sender) >= pendingBuyList[msg.sender].totalAmount,"Balance Not Enough");

        token.safeTransferFrom(msg.sender,address(this),pendingBuyList[msg.sender].totalAmount);
        token.safeTransfer(company_address,pendingBuyList[msg.sender].totalAmount);

        _buyFromMint(pendingBuyList[msg.sender].totalAmount,msg.sender);

        delete pendingBuyList[msg.sender];
        
    }

    function buyNewToyWithPass(uint256 _tokenId) external {
        require(pendingBuyList[msg.sender].isNewBuy == true,"New Buy Not Allowed");
        require(pendingBuyList[msg.sender].expiryTime >= block.timestamp);

        require(toysList[_tokenId].isClose == false);

        IERC20 token = IERC20(usdtAddress);
        IERC721 nftPass = IERC721(toysPass);

        require(nftPass.isApprovedForAll(msg.sender,address(this)),"Set Approval");
        require(nftPass.ownerOf(_tokenId) == msg.sender,"Not Owner");
        
        uint256 _passValue = nftPass.passprice(_tokenId);
        uint256 _balancedebit;

        if(pendingBuyList[msg.sender].totalAmount > _passValue)
            _balancedebit = pendingBuyList[msg.sender].totalAmount.sub(_passValue);
        else
            _balancedebit = 0;

        if(_balancedebit >0)
        {
            require(token.allowance(msg.sender,address(this)) > _balancedebit,"Not Approved");
            require(token.balanceOf(msg.sender) >= _balancedebit,"Balance Not Enough");

            token.safeTransferFrom(msg.sender,address(this),_balancedebit);
            token.safeTransfer(company_address,_balancedebit);
        }
        nftPass.safeTransferFrom(msg.sender,address(this),_tokenId);

        _buyFromMint(pendingBuyList[msg.sender].totalAmount,msg.sender);

        delete pendingBuyList[msg.sender];
    }

    function _buyFromMint(uint256 _amount,address _address) internal {
        IERC721 nft = IERC721(toysNFT);

        uint256 tokenId = nft.mint(_amount,_address);

        toysList[tokenId].currentPrice = _amount;
        toysList[tokenId].currentOwner = _address;
        toysList[tokenId].stakeStatus = false;
        toysList[tokenId].isOnSales = false;

        emit buyBidEvent(_address,tokenId,_amount);
    }

    function stakeOnGems(uint256 _amount) external {
        
         IERC20 token = IERC20(gemsAddress);
        
        require(token.allowance(msg.sender,address(this)) >= _amount,"Approval");
        
        token.safeTransferFrom(msg.sender,address(this),_amount);
        stakeList[msg.sender] = stakeList[msg.sender].add(_amount);
        totalStakeGems = totalStakeGems.add(_amount);
    }

    function unstakeOnGems(uint256 _amount) external {
        require(stakeList[msg.sender] >= _amount,"Didnt have enough Stake");
        IERC20 token = IERC20(gemsAddress);
        token.safeTransfer(msg.sender,_amount);
        stakeList[msg.sender] = stakeList[msg.sender].sub(_amount);
        totalStakeGems = totalStakeGems.sub(_amount);

    }

    event buyGemsEvent(address indexed _addr,uint256 _amount);
    event buyWipesEvent(address indexed _addr,uint256 _amount);
    event stakeEvent(address indexed _addr , uint256 indexed _token,uint256 _amount);
    event claimEvent(address indexed _addr,uint256 _amount);
    event buyBidEvent(address indexed _addr,uint256 _tokenId,uint256 _amount);
    event snapPay(address indexed _addr,uint256 _tokenId,uint256 _amount);
}