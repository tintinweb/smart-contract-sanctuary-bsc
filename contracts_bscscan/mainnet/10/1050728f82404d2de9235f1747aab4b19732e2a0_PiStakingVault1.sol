// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity 0.7.4;

import "./interfaces/IWETH.sol";
import "./interfaces/IPi.sol";
import "./interfaces/IStrategy.sol";
import "./interfaces/INFT.sol";

import "./libraries/UniswapV2Library.sol";
import "./openzeppelinupgradeable/math/MathUpgradeable.sol";
import "./openzeppelinupgradeable/math/SafeMathUpgradeable.sol";
import "./openzeppelinupgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "./openzeppelinupgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "./openzeppelinupgradeable/utils/PausableUpgradeable.sol";
import "./openzeppelinupgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IpBNB_Direct.sol";
import "./interfaces/IPBNB.sol";

abstract contract TokensRecoverable is OwnableUpgradeable
{   
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function recoverTokens(IERC20Upgradeable token) public onlyOwner() 
    {
        require (canRecoverTokens(token));
        
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    function recoverERC1155(IERC1155 token, uint256 tokenId, uint256 amount) public onlyOwner() 
    {        
        token.safeTransferFrom(address(this),msg.sender,tokenId,amount,"0x");
    }

    function recoverERC721(IERC721 token, uint256 tokenId) public onlyOwner() 
    {        
        token.safeTransferFrom(address(this),msg.sender,tokenId);
    }

    function recoverETH(uint256 amount) public onlyOwner() 
    {        
        msg.sender.transfer(amount);
    }    

    function canRecoverTokens(IERC20Upgradeable token) internal virtual view returns (bool) 
    { 
        return address(token) != address(this); 
    }
}

// Have fun reading it. Hopefully it's bug-free. God bless.
contract PiStakingVault1 is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable, TokensRecoverable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // Info of each userInfo[_pid][msg.sender].
    struct UserInfo {
        uint256 amount;         // How many LP tokens/ WANT tokens the user has staked.
        uint256 shares; 
        uint256[] AllNFTIds;
    }
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    mapping(uint256 => mapping(address => mapping(uint256=>uint256))) public NFTIdsDeposits; // NFT id, quantity

    // Info of each pool.
    struct PoolInfo {
        uint256 PiTokenAmtPerNFT;  // this amount of Pi will be given to user for each NFT staked
        address nativeToken;           // Address of native token
        address nativeNFTtoken;           // Address of native NFT token
        uint256 ERC1155NFTid;
        bool isERC1155;
        address wantToken;           // Address of LP token / want contract
        uint256 depositFeeNative;      // Deposit fee in basis points 100000 = 100%
        address strat;             // Strategy address that will auto compound want tokens
        uint256 max_slots; // active stakes cannot be more than max_slots
        uint256 max_per_user; // 1 user cannot stake NFTs more than max_per_user
    }
    // Info of each pool.
    PoolInfo[] public poolInfo;

    mapping(uint256=>uint256) public slots_filled; // pid => nfts quantity

    // The Pi TOKEN!
    IPi public Pi;

    IpBNB_Direct public pBNBDirect;
    IPBNB public pBNB;

    // Deposit Fee address
    address public feeAddress;

    mapping(address => bool) public poolExistence;    
    uint256 slippage; // 10% = 10000
    address public wrappedBNB;
    IUniswapV2Router02 private uniswapV2Router; 
    IUniswapV2Factory private uniswapV2Factory; 
    uint256 public timeLockInSecs;
    mapping(address=>uint256) public lockTimeStamp; 
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SetFeeAddress(address indexed user, address indexed newAddress);

    receive() external payable{
    } 

    function initialize(        
        IPi _Pi,
        address _feeAddress,
        IpBNB_Direct _pBNBDirect,
        IPBNB _pBNB
        )  public initializer  {
        
        __Ownable_init_unchained();
        Pi = _Pi;
        feeAddress = _feeAddress;
        pBNBDirect = _pBNBDirect;
        pBNB = _pBNB;

        wrappedBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Factory = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73); //IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);

        slippage = 10000;// 10% 
        timeLockInSecs = 14 days;

        IERC20Upgradeable(address(Pi)).approve(address(uniswapV2Router), uint256(-1));   
        IERC20Upgradeable(address(Pi)).approve(address(pBNBDirect), uint256(-1));   

    }


    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function allNFTsDeposited(uint256 _pid, address _user) external view returns(uint[] memory){
        return userInfo[_pid][_user].AllNFTIds;
    }

    modifier nonDuplicated(address _wantToken) {
        require(!poolExistence[_wantToken], "nonDuplicated: duplicated");
        _;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner{
        _unpause();
    }
    

    // Add a new lp to the pool. Can only be called by the owner.
    // [10,100,200] = 10 -> low risk, 100 -> medium, 200 -> high risk vault
    function add( uint256 _piTokenAmtPerNFT, address _nativeToken, address _nativeNFTtoken, uint256 _ERC1155NFTid, bool _isERC1155, address _wantToken, uint256 _depositFeeNative, 
        address _strat, uint256 _max_slots, uint256 _max_per_user) public onlyOwner nonDuplicated(_wantToken) {
        
        require(_max_slots>_max_per_user,"_max_slots should be more than _max_per_user");
        require(_wantToken == IStrategy(_strat).wantAddress(),"wantToken not equal to pool strat wantAddress");
        require(_nativeToken!=address(0),"_nativeToken shouldnot be zero address");
        require(_strat!=address(0),"_strat shouldnot be zero address");
        // require(_depositFeeNative>0,"_depositFeeNative should be more than 0");
        require(_piTokenAmtPerNFT>0,"_piTokenAmtPerNFT should be more than 0");

        try IUniswapV2Pair(_wantToken).factory(){
            require(address(Pi) != IUniswapV2Pair(_wantToken).token0(),"wantToken equal to pool strat token0");
            require(address(Pi) != IUniswapV2Pair(_wantToken).token1(),"wantToken equal to pool strat token1");
        }
        catch{
            require(address(Pi) != _wantToken,"wantToken equal to Pi");
        }
        

        poolExistence[_wantToken] = true;
        poolInfo.push(PoolInfo({
            PiTokenAmtPerNFT : _piTokenAmtPerNFT,
            nativeToken : _nativeToken,
            nativeNFTtoken : _nativeNFTtoken,
            ERC1155NFTid: _ERC1155NFTid,
            isERC1155 : _isERC1155,
            wantToken : _wantToken,
            depositFeeNative : _depositFeeNative, // native tokens required as fee => either of 10, 100, 1000 as per risk of vault => 10000, 100000 or 1000000
            strat: _strat,
            max_slots : _max_slots,
            max_per_user : _max_per_user
        }));

        IERC20Upgradeable(_wantToken).approve(feeAddress, uint256(-1));   
        IERC20Upgradeable(_wantToken).approve(address(uniswapV2Router), uint256(-1));   

        try IUniswapV2Pair(_wantToken).factory(){
            IERC20Upgradeable(IUniswapV2Pair(_wantToken).token0()).approve(address(uniswapV2Router), uint256(-1));   
            IERC20Upgradeable(IUniswapV2Pair(_wantToken).token1()).approve(address(uniswapV2Router), uint256(-1));   
        } catch{}

    }

    // Update the given pool's Pi allocation point and deposit fee. Can only be called by the owner.
    function set(uint256 _pid, uint256 _depositFeeNative, uint256 _max_slots, uint256 _max_per_user, uint256 _piTokenAmtPerNFT) public onlyOwner {

        poolInfo[_pid].depositFeeNative = _depositFeeNative;
        poolInfo[_pid].max_slots = _max_slots;
        poolInfo[_pid].max_per_user = _max_per_user;
        poolInfo[_pid].PiTokenAmtPerNFT = _piTokenAmtPerNFT;

    }

   
    // View function to see your initial deposit
    function balanceOf(uint256 _pid, address _user) public view returns (uint256) {
        return userInfo[_pid][_user].amount;
    }

    function zapEthToToken(address _token1, uint256 _amount) internal{
        uint slippageFactor=(SafeMathUpgradeable.sub(100000,slippage)).div(1000); // 100 - slippage => will return like 98000/1000 = 98 for default     
        address[] memory path2 = new address[](2);
        path2[0] = wrappedBNB;
        path2[1] = _token1; 
        if(path2[0]!=path2[1])
        {
            (uint256[] memory amounts2) = UniswapV2Library.getAmountsOut(address(uniswapV2Factory), _amount, path2);
            uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: _amount}(amounts2[1].mul(slippageFactor).div(100), path2, address(this), block.timestamp+300);
        }
        else 
            IWETH(wrappedBNB).deposit{ value: _amount }();
        
        delete path2;
    }

    // _erc721tokenId send if NFT token is ERC 721
    function deposit(uint256 _pid, uint256 totalNFTs, uint256[] memory _erc721tokenIds) public nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        uint256 _amount;
        uint256 allocatedPi; 
        lockTimeStamp[msg.sender] = block.timestamp.add(timeLockInSecs);


        if(pool.isERC1155){
            require(totalNFTs>0,"amount of totalNFTs to transfer cannot be 0");

            _amount = totalNFTs.mul(pool.depositFeeNative);
            allocatedPi = totalNFTs.mul(pool.PiTokenAmtPerNFT);

            IERC1155(pool.nativeNFTtoken).safeTransferFrom( msg.sender, address(this), pool.ERC1155NFTid, totalNFTs, "0x");
            // donot duplicate erc1155 token ids
            if(NFTIdsDeposits[_pid][msg.sender][pool.ERC1155NFTid]==0){
                userInfo[_pid][msg.sender].AllNFTIds.push(pool.ERC1155NFTid);
            }
            NFTIdsDeposits[_pid][msg.sender][pool.ERC1155NFTid]=NFTIdsDeposits[_pid][msg.sender][pool.ERC1155NFTid].add(totalNFTs);
            slots_filled[_pid]=slots_filled[_pid].add(totalNFTs);
            require(slots_filled[_pid]<=pool.max_slots,"Max slots filled");
            require(NFTIdsDeposits[_pid][msg.sender][pool.ERC1155NFTid]<=pool.max_per_user,"Max per user already done");

        } else // erc721
        {
            require(_erc721tokenIds.length>0,"amount of totalNFTs to transfer cannot be 0");

            _amount = _erc721tokenIds.length.mul(pool.depositFeeNative);
            allocatedPi = _erc721tokenIds.length.mul(pool.PiTokenAmtPerNFT);

            for(uint i=0;i<_erc721tokenIds.length;i++){
                IERC721(pool.nativeNFTtoken).transferFrom(msg.sender, address(this), _erc721tokenIds[i]);
                userInfo[_pid][msg.sender].AllNFTIds.push(_erc721tokenIds[i]);
                NFTIdsDeposits[_pid][msg.sender][_erc721tokenIds[i]]=1;
                slots_filled[_pid]=slots_filled[_pid].add(1);
            }
            require(slots_filled[_pid]<=pool.max_slots,"Max slots filled");
            require(userInfo[_pid][msg.sender].AllNFTIds.length<=pool.max_per_user,"Max per user already done");

        }
        if(_amount!=0)
            IERC20Upgradeable(pool.nativeToken).safeTransferFrom(msg.sender, feeAddress, _amount);

        // market buy 
        uint256 prevWantAmount = IERC20(pool.wantToken).balanceOf(address(this)); 
        
        // so that stack is not deep -> making copies
        uint poolId = _pid;
        uint256 amount = _amount;

        uint slippageFactor=(SafeMathUpgradeable.sub(100000,slippage)).div(1000); // 100 - slippage => will return like 98000/1000 = 98 for default     
        uint prevpbnbBal = pBNB.balanceOf(address(this));
        uint prevBNBBal = address(this).balance;
        pBNBDirect.easySellToPBNB(allocatedPi);
        pBNB.withdraw(pBNB.balanceOf(address(this)).sub(prevpbnbBal));

        uint256 bnbAmtAfterSell = address(this).balance.sub(prevBNBBal);

        // check if uniswap pair
        try IUniswapV2Pair(pool.wantToken).factory(){
            
            address wantToken1 = pool.wantToken;
            uint256 prevToken0Bal = IERC20Upgradeable(IUniswapV2Pair(pool.wantToken).token0()).balanceOf(address(this)); 
         
            zapEthToToken(IUniswapV2Pair(wantToken1).token0(), bnbAmtAfterSell.div(2));

            uint256 prevToken1Bal = IERC20Upgradeable(IUniswapV2Pair(wantToken1).token1()).balanceOf(address(this)); 

            zapEthToToken(IUniswapV2Pair(wantToken1).token1(), bnbAmtAfterSell.div(2));

            uniswapV2Router.addLiquidity(
                IUniswapV2Pair(wantToken1).token0(), 
                IUniswapV2Pair(wantToken1).token1(), 
                IERC20Upgradeable(IUniswapV2Pair(wantToken1).token0()).balanceOf(address(this)).sub(prevToken0Bal), 
                IERC20Upgradeable(IUniswapV2Pair(wantToken1).token1()).balanceOf(address(this)).sub(prevToken1Bal), 
                100, 
                100,
                address(this), 
                block.timestamp+900);
        }
        catch {
            zapEthToToken(pool.wantToken, bnbAmtAfterSell);
        }

        uint256 WantTokenReceivedInContractAfterSwap = IERC20Upgradeable(pool.wantToken).balanceOf(address(this)).sub(prevWantAmount);
        IERC20Upgradeable(pool.wantToken).safeIncreaseAllowance(pool.strat, WantTokenReceivedInContractAfterSwap);
        
        uint256 sharesAdded = IStrategy(pool.strat).deposit(msg.sender, WantTokenReceivedInContractAfterSwap);

        userInfo[poolId][msg.sender].amount = userInfo[poolId][msg.sender].amount.add(WantTokenReceivedInContractAfterSwap);
        userInfo[poolId][msg.sender].shares = userInfo[poolId][msg.sender].shares.add(sharesAdded);
        emit Deposit(msg.sender, poolId, amount);
    }

    // to see the updated LPs of user
    function getusercompounds(uint256 _pid, address _useraddress) public view returns (uint256){
        
        PoolInfo storage pool = poolInfo[_pid];
        uint256 wantLockedTotal =
            IStrategy(pool.strat).wantLockedTotal();
        uint256 sharesTotal = IStrategy(pool.strat).sharesTotal();
        if(sharesTotal==0)
            return 0;

        uint256 amount = userInfo[_pid][_useraddress].shares.mul(wantLockedTotal).div(sharesTotal);
        if(userInfo[_pid][_useraddress].amount>amount) // can give 99999 due to division for 100000
            return userInfo[_pid][_useraddress].amount;
        else
            return amount;
    }

    function zapTokenToEth(address _token1, uint256 _amount) internal{
        uint slippageFactor=(SafeMathUpgradeable.sub(100000,slippage)).div(1000); // 100 - slippage => will return like 98000/1000 = 98 for default     
        address[] memory path = new address[](2);
        path[0] = _token1;
        path[1] = wrappedBNB; 
        if(path[0]!=path[1])
        {
            (uint256[] memory amounts) = UniswapV2Library.getAmountsOut(address(uniswapV2Factory), _amount, path);
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(_amount, amounts[1].mul(slippageFactor).div(100), path, address(this), block.timestamp+300);
        }
        else
            IWETH(wrappedBNB).withdraw(_amount);
            
        delete path;
    }



    // Withdraw LP tokens 
    // all NFTs will be withdrawn
    function withdrawAll(uint256 _pid) public nonReentrant  {
        
        require(lockTimeStamp[msg.sender]<=block.timestamp,"Cannot withdraw before timelock finishes");
        PoolInfo storage pool = poolInfo[_pid];
        uint256 _amount = userInfo[_pid][msg.sender].amount;

        uint256 wantLockedTotal =
            IStrategy(poolInfo[_pid].strat).wantLockedTotal();
        uint256 sharesTotal = IStrategy(poolInfo[_pid].strat).sharesTotal();

        require(userInfo[_pid][msg.sender].shares > 0, "userInfo[_pid][msg.sender].shares is 0");
        require(sharesTotal > 0, "sharesTotal is 0");

        // give nft back to user
        if(pool.isERC1155){

            slots_filled[_pid]=slots_filled[_pid].sub(NFTIdsDeposits[_pid][msg.sender][pool.ERC1155NFTid]);
            IERC1155(pool.nativeNFTtoken).safeTransferFrom( address(this), msg.sender, pool.ERC1155NFTid, NFTIdsDeposits[_pid][msg.sender][pool.ERC1155NFTid], "0x");

            uint[] memory auxArray;
            userInfo[_pid][msg.sender].AllNFTIds = auxArray;
            NFTIdsDeposits[_pid][msg.sender][pool.ERC1155NFTid]=0;

        } else // erc721
        {
            uint256[] memory erc721tokenIds = userInfo[_pid][msg.sender].AllNFTIds;
            for(uint i=0;i<erc721tokenIds.length;i++){
                IERC721(pool.nativeNFTtoken).transferFrom( address(this), msg.sender, erc721tokenIds[i]);
                NFTIdsDeposits[_pid][msg.sender][erc721tokenIds[i]]=0;
            }
            slots_filled[_pid]=slots_filled[_pid].sub(erc721tokenIds.length);

            uint[] memory auxArray;
            userInfo[_pid][msg.sender].AllNFTIds = auxArray;
        }


        // Withdraw want tokens
        uint256 amount = userInfo[_pid][msg.sender].shares.mul(wantLockedTotal).div(sharesTotal);

        uint256 rewardForUser = 0;

        if (amount < _amount) {
            amount = _amount;
        }
        else rewardForUser = amount.sub(_amount); // only the reward

        if (amount > 0) {
            uint256 sharesRemoved =
                IStrategy(poolInfo[_pid].strat).withdraw(msg.sender, amount);

            if (sharesRemoved > userInfo[_pid][msg.sender].shares) 
                userInfo[_pid][msg.sender].shares = 0; 
            else
                userInfo[_pid][msg.sender].shares = userInfo[_pid][msg.sender].shares.sub(sharesRemoved);

            if(amount > userInfo[_pid][msg.sender].amount)
                userInfo[_pid][msg.sender].amount = 0;
            else
                userInfo[_pid][msg.sender].amount = userInfo[_pid][msg.sender].amount.sub(amount);
            

            uint256 amountForVaults = amount.sub(rewardForUser);

            if(amountForVaults>0){
                marketBuyAndTransfer(pool.wantToken, address(this), amountForVaults);
            }
            if(rewardForUser>0)            
                marketBuyAndTransfer(pool.wantToken, msg.sender, rewardForUser);
        }

        emit Withdraw(msg.sender, _pid, amount);
    }


    function marketBuyAndTransfer(address _tokenAddress, address _to, uint256 _amount) internal{

        uint256 prevBNB = address(this).balance;

        try IUniswapV2Pair(_tokenAddress).factory(){

            uint256 prevBalanceToken0 = IERC20(IUniswapV2Pair(_tokenAddress).token0()).balanceOf(address(this)); 
            uint256 prevBalanceToken1 = IERC20(IUniswapV2Pair(_tokenAddress).token1()).balanceOf(address(this)); 
            
            if(IUniswapV2Pair(_tokenAddress).token0()==wrappedBNB){
                uniswapV2Router.removeLiquidityETH(IUniswapV2Pair(_tokenAddress).token1(), _amount, 100, 100, address(this), block.timestamp+300);        
                uint256 amountToken1 = IERC20(IUniswapV2Pair(_tokenAddress).token1()).balanceOf(address(this)).sub(prevBalanceToken1); 
                zapTokenToEth(IUniswapV2Pair(_tokenAddress).token1(), amountToken1);

            }
            else if(IUniswapV2Pair(_tokenAddress).token1()==wrappedBNB){
                uniswapV2Router.removeLiquidityETH(IUniswapV2Pair(_tokenAddress).token0(), _amount, 100, 100, address(this), block.timestamp+300);
                uint256 amountToken0 = IERC20(IUniswapV2Pair(_tokenAddress).token0()).balanceOf(address(this)).sub(prevBalanceToken0); 
                zapTokenToEth(IUniswapV2Pair(_tokenAddress).token0(), amountToken0);
            }
            else{
                uniswapV2Router.removeLiquidity(IUniswapV2Pair(_tokenAddress).token0(), IUniswapV2Pair(_tokenAddress).token1(), _amount, 100, 100, address(this), block.timestamp+300);
                uint256 amountToken0 = IERC20(IUniswapV2Pair(_tokenAddress).token0()).balanceOf(address(this)).sub(prevBalanceToken0); 
                uint256 amountToken1 = IERC20(IUniswapV2Pair(_tokenAddress).token1()).balanceOf(address(this)).sub(prevBalanceToken1); 

                zapTokenToEth(IUniswapV2Pair(_tokenAddress).token0(), amountToken0);
                zapTokenToEth(IUniswapV2Pair(_tokenAddress).token1(), amountToken1);
            }

        }
        catch{
            zapTokenToEth(_tokenAddress, _amount);
        }

        uint256 totalBNB = address(this).balance.sub(prevBNB);
        uint prevPi = Pi.balanceOf(address(this));
        pBNBDirect.easyBuy{ value: totalBNB }();
        
        if(_to != address(this) )
            Pi.transfer(_to, Pi.balanceOf(address(this)).sub(prevPi));

    }

    function setFeeAddress(address _feeAddress) external onlyOwner{
        feeAddress = _feeAddress;
        emit SetFeeAddress(msg.sender, _feeAddress);
    }

    // change strat for pool id
    function changeStratForPool(uint256 _pid, address _stratAddress) external onlyOwner{
        PoolInfo storage pool = poolInfo[_pid];
        pool.strat = _stratAddress;
    }

    function setSlippage(uint _slippage) external onlyOwner{
        slippage = _slippage;
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external  returns(bytes4){
        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external  returns(bytes4){
        return 0xbc197c81;
    }     
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

import "./IERC20.sol";
import "./IWrappedERC20Events.sol";

interface IWETH is IERC20, IWrappedERC20Events
{    
    function deposit() external payable;
    function withdraw(uint256 _amount) external;
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;
import "./IGatedERC20.sol";

interface IPi is IGatedERC20
{
    
    function FEE() external view returns (uint256);
    function FEE_ADDRESS() external view returns (address);
    function isIgnored(address _ignoredAddress) external view returns (bool);
    
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;
import "../openzeppelinupgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IStrategy {
    // function poolLength() external view returns (uint256);

    // function userInfo() external view returns (uint256);

    /// @notice Info of each MCV2 user.
    /// `amount` LP token amount the user has provided.
    /// `rewardDebt` The amount of SUSHI entitled to the user.
    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;
    }

     // Info of each pool.
    struct PoolInfo {
        IERC20Upgradeable lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. dMagics to distribute per block.
        uint256 lastRewardBlockTime;  // Last block number that dMagics distribution occurs.
        uint256 accdMagicPerShare;   // Accumulated dMagics per share, times 1e12. See below.
        uint16 depositFeeBP;      // Deposit fee in basis points
    }

    function initialize(        
        address _dMagicFarmAddress,
        uint256 _dMagicVaultPoolid,
        address _wantAddress, // SLP token from token0 and token1 
        address _token0Address,
        address _token1Address,
        address _SUSHIVaultAddress, // Sushi Staking Contract
        uint256 _SUSHIPoolId, // Sushi Pool id of Vault
        address _earnedAddress // WMATIC token
    ) external;

    function userInfo(uint256 pid, address user) external view returns (UserInfo memory info);
    function poolInfo(uint256 pid) external view returns (PoolInfo memory pools);
    function sharesTotal() external view returns (uint256);
    function wantLockedTotal() external view returns (uint256);
    
    function wantAddress() external view returns (address);
    function token0Address() external view returns (address);
    function token1Address() external view returns (address);

    function deposit(address userAddress, uint256 _amount) external returns (uint256 sharesAdded);

    function withdraw(address userAddress, uint256 _amount) external returns (uint256 sharesRemoved);
    
    function upgradeTo(address implementation) external ;

}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: node_modules\@openzeppelin\contracts\token\ERC721\IERC721.sol


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transfered from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// File: node_modules\@openzeppelin\contracts\token\ERC721\IERC721Metadata.sol


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    function totalSupply(
        uint256 _id
    ) external view returns (uint256);
    
    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function setContracts(address _GameContract) external returns (bool);

    function create( address _to, uint256 _initialSupply, string calldata _Uri, bytes calldata _data) external returns(uint256) ;
  
    function mint(address to, uint256 id, uint256 value, bytes calldata data) external;

    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external;

    function burn(address owner, uint256 id, uint256 value) external;

    function burnBatch(address owner, uint256[] calldata ids, uint256[] calldata values) external;


    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

import "../interfaces/IUniswapV2Pair.sol";
import "./SafeMath.sol";


library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20Upgradeable.sol";
import "../../math/SafeMathUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./ContextUpgradeable.sol";
import "../proxy/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

interface IpBNB_Direct 
{


    function estimateBuy(uint256 piBNBAmountIn) external view returns (uint256 PiAmount);

    function estimateSell(uint256 PiAmountIn) external view returns (uint256 ethAmount);

    function easyBuy() external payable returns (uint256 PiAmount);
    function easyBuyFromPBNB(uint256 piBNBIn) external  returns (uint256 PiAmount);

    function easySell(uint256 PiAmountIn) external returns (uint256 piBNBAmount);
    function easySellToPBNB(uint256 PiAmountIn) external returns (uint256 piBNBAmount);

    function buyFromPBNB(uint256 piBNBIn, uint256 dMagicOutMin) external returns (uint256 PiAmount);
    function buy(uint256 piBNBIn, uint256 dMagicOutMin) external payable returns (uint256 PiAmount);

    function sell(uint256 PiAmountIn, uint256 piBNBOutMin) external returns (uint256 piBNBAmount);
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;
import "./IWETH.sol";

interface IPBNB is IWETH
{
    
    function FEE() external view returns (uint256);
    function FEE_ADDRESS() external view returns (address);
    function isIgnored(address _ignoredAddress) external view returns (bool);
    
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

interface IERC20 
{
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address _recipient, uint256 _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

interface IWrappedERC20Events
{
    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

import "./IERC20.sol";
import "./IPiTransferGate.sol";

interface IGatedERC20 is IERC20
{
    function transferGate() external view returns (IPiTransferGate);

    function setTransferGate(IPiTransferGate _transferGate) external;
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "./IOwned.sol";
import "./ITokensRecoverable.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";


enum AddressState
{
    Unknown,
    NotPool,
    DisallowedPool,
    AllowedPool
} 
struct TransferGateTarget
{
    address destination;
    uint256 amount;
}

interface IPiTransferGate is IOwned, ITokensRecoverable
{   


    function allowedPoolTokensCount() external view returns (uint256);
    function setUnrestrictedController(address unrestrictedController, bool allow) external;

    function setFreeParticipant(address participant, bool free) external;

    function setUnrestricted(bool _unrestricted) external;

    function setParameters(address _dev, address _stake, uint16 _stakeRate, uint16 _burnRate, uint16 _devRate) external;
    function allowPool(IUniswapV2Factory _uniswapV2Factory, IERC20 token) external;

    function safeAddLiquidity(IUniswapV2Router02 _uniswapRouter02, IERC20 token, uint256 tokenAmount, uint256 PiAmount//, uint256 minTokenAmount, uint256 minPiAmount
// ,uint256 deadline //stack deep issue coming so had to use fix values
    ) external returns (uint256 PiUsed, uint256 tokenUsed, uint256 liquidity);

    function handleTransfer(address msgSender, address from, address to, uint256 amount) external
    returns (uint256 burn, TransferGateTarget[] memory targets);

  
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

interface IOwned
{
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);

    function transferOwnership(address newOwner) external;
    function claimOwnership() external;
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

import "./IERC20.sol";

interface ITokensRecoverable
{
    function recoverTokens(IERC20 token) external;
    function recoverETH(uint256 amount) external; 
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
        uint deadline
    ) external;
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: J-J-J-JENGA!!!
pragma solidity ^0.7.4;

/* ROOTKIT:
O wherefore art thou 8 point O
*/

library SafeMath 
{
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) 
        {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}