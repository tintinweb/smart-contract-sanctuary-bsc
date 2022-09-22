// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IBEP165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IBEP165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IBEP165).interfaceId;
    }
}

interface IBEP721 is IBEP165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IBEP721Metadata is IBEP721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IRouter {
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
        
        function addLiquidityBNB(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountBNB, uint liquidity);
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function removeLiquidityBNB(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountBNB);

}

interface IPancakeRouter {
    function WETH() external pure returns (address);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface ILpStaking {
    function stakeNonces (address) external view returns (uint256);
    function stake(uint256 amount) external;
    function stakeFor(uint256 amount, address user) external;
    function getCurrentLPPrice() external view returns (uint);
    function getReward() external;
    function withdraw(uint256 nonce) external;
    function rewardDuration() external returns (uint256);
}

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external;
    function withdraw(uint) external;
    function approve(address spender, uint value) external returns (bool);
}

interface ILending {
    function mintWithBnb(address receiver) external payable returns (uint256 mintAmount);
    function tokenPrice() external view returns (uint256);
    function burnToBnb(address receiver, uint256 burnAmount) external returns (uint256 loanAmountPaid);
}

contract SmartLPStorage is Initializable, ERC165, ContextUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {    
    IWBNB public WBNB;
    IERC20Upgradeable public purchaseToken;
    IRouter public swapRouter;
    ILpStaking public lpStakingBnbNbu;
    ILpStaking public lpStakingBnbGnbu;
    ILending public lendingContract;
    IERC20Upgradeable public nbuToken;
    IERC20Upgradeable public gnbuToken;

    uint public tokenCount;
    uint public minPurchaseAmountToken;
    uint public rewardDuration;
    uint public lockTime;
    
    struct UserSupply { 
      address ProvidedToken;
      uint ProvidedAmount;
      uint NbuBnbLpAmount;
      uint GnbuBnbLpAmount;
      uint NbuBnbStakeNonce;
      uint GnbuBnbStakeNonce;
      uint LendedBNBAmount;
      uint LendedITokenAmount;
      uint SupplyTime;
      uint TokenId;
      bool IsActive;
    }
    
    mapping(uint => uint[]) internal _userRewards;
    mapping(uint => uint256) internal _balancesRewardEquivalentBnbNbu;
    mapping(uint => uint256) internal _balancesRewardEquivalentBnbGnbu;
    mapping(uint => UserSupply) public tikSupplies;
    mapping(uint => uint256) public weightedStakeDate;

    string internal _name;
    string internal _symbol;
    mapping(uint256 => address) internal _owners;
    mapping(address => uint256) internal _balances;
    mapping(uint256 => address) internal _tokenApprovals;
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
    mapping(address => uint[]) internal _userTokens;
    IPancakeRouter public pancakeRouter;

    event BuySmartLP(address indexed user, uint indexed tokenId, address providedToken, uint providedBnb, uint supplyTime);
    event WithdrawRewards(address indexed user, uint indexed tokenId, uint totalNbuReward);
    event BalanceRewardsNotEnough(address indexed user, uint indexed tokenId, uint totalNbuReward);
    event BurnSmartLP(uint indexed tokenId);
    event UpdateSwapRouter(address indexed newSwapRouterContract);
    event UpdateLpStakingBnbNbu(address indexed newLpStakingAContract);
    event UpdateLpStakingBnbGnbu(address indexed newLpStakingBContract);
    event UpdateLendingContract(address indexed newLending);
    event UpdateTokenNbu(address indexed newToken);
    event UpdateTokenGnbu(address indexed newToken);
    event UpdateMinPurchaseAmountToken(uint indexed newAmount);
    event Rescue(address indexed to, uint amount);
    event RescueToken(address indexed to, address indexed token, uint amount);
}

contract SmartLP is SmartLPStorage, IBEP721, IBEP721Metadata {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;
    
    address public target;

    function initialize(
        address _swapRouter, 
        address _pancakeRouter,
        address _wbnb,
        address _purchaseToken,
        address _nbuToken,
        address _gnbuToken, 
        address _bnbNbuPair, 
        address _gnbuBnbPair, 
        address _lpStakingBnbNbu, 
        address _lpStakingBnbGnbu
    ) public initializer {
        __Context_init();
        __Ownable_init();
        __ReentrancyGuard_init();
        require(AddressUpgradeable.isContract(_swapRouter), "NimbusSmartLP_V1: Not contract");
        require(AddressUpgradeable.isContract(_wbnb), "NimbusSmartLP_V1: Not contract");
        require(AddressUpgradeable.isContract(_purchaseToken), "NimbusSmartLP_V1: Not contract");
        require(AddressUpgradeable.isContract(_nbuToken), "NimbusSmartLP_V1: Not contract");
        require(AddressUpgradeable.isContract(_gnbuToken), "NimbusSmartLP_V1: Not contract");
        require(AddressUpgradeable.isContract(_bnbNbuPair), "NimbusSmartLP_V1: Not contract");
        require(AddressUpgradeable.isContract(_gnbuBnbPair), "NimbusSmartLP_V1: Not contract");
        require(AddressUpgradeable.isContract(_lpStakingBnbNbu), "NimbusSmartLP_V1: Not contract");
        require(AddressUpgradeable.isContract(_lpStakingBnbGnbu), "NimbusSmartLP_V1: Not contract");

        _name = "Smart LP";
        _symbol = "SL";
        
        swapRouter = IRouter(_swapRouter);
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        purchaseToken = IERC20Upgradeable(_purchaseToken);
        WBNB = IWBNB(_wbnb);
        nbuToken = IERC20Upgradeable(_nbuToken);
        gnbuToken = IERC20Upgradeable(_gnbuToken);
        lpStakingBnbNbu = ILpStaking(_lpStakingBnbNbu);
        lpStakingBnbGnbu = ILpStaking(_lpStakingBnbGnbu);
        lendingContract = ILending(address(0));

        rewardDuration = ILpStaking(_lpStakingBnbNbu).rewardDuration();
        minPurchaseAmountToken = 500 ether;
        lockTime = 365 days;

        IERC20Upgradeable(_nbuToken).approve(_swapRouter, type(uint256).max);
        IERC20Upgradeable(_gnbuToken).approve(_swapRouter, type(uint256).max);
        IERC20Upgradeable(_purchaseToken).approve(_pancakeRouter, type(uint256).max);
        IERC20Upgradeable(_bnbNbuPair).approve(address(_swapRouter), type(uint256).max);
        IERC20Upgradeable(_bnbNbuPair).approve(address(_lpStakingBnbNbu), type(uint256).max);
        IERC20Upgradeable(_gnbuBnbPair).approve(address(_lpStakingBnbGnbu), type(uint256).max);  
        IERC20Upgradeable(_gnbuBnbPair).approve(address(_swapRouter), type(uint256).max);  
    }

    receive() external payable {
        assert(msg.sender == address(WBNB) || msg.sender == address(swapRouter) || msg.sender == address(pancakeRouter));
    }
    
    // ========================== SmartLP functions ==========================

    function buySmartLPforToken(uint256 amount) external {
      require(amount >= minPurchaseAmountToken, 'SmartLP: Token price is more than sent');
      TransferHelper.safeTransferFrom(address(purchaseToken), msg.sender, address(this), amount);

      address[] memory path = new address[](2);
      path[0] = address(purchaseToken);
      path[1] = pancakeRouter.WETH();
      (uint[] memory amountsTokenBnb) = pancakeRouter.swapExactTokensForETH(amount, 0, path, address(this), block.timestamp + 1200);
      uint256 amountBNB = amountsTokenBnb[1];
      uint256 tokenId = buySmartLP(amountBNB);
      tikSupplies[tokenId].ProvidedToken = address(purchaseToken);
      tikSupplies[tokenId].ProvidedAmount = amount;

      emit BuySmartLP(msg.sender, tokenCount, address(purchaseToken), amount, block.timestamp);
    }

    function buySmartLP(uint256 amountBNB) private returns (uint256){
      uint swapAmount = amountBNB/4;
      tokenCount = ++tokenCount;
      
      address[] memory path = new address[](2);
      path[0] = address(WBNB);
      path[1] = address(nbuToken);
      (uint[] memory amountsBnbNbuSwap) = swapRouter.swapExactBNBForTokens{value: swapAmount}(0, path, address(this), block.timestamp);

      path[1] = address(gnbuToken);      
      (uint[] memory amountsBnbGnbuSwap) = swapRouter.swapExactBNBForTokens{value: swapAmount}(0, path, address(this), block.timestamp);
      
      amountBNB -= swapAmount * 2;
      
      (, uint amountBnbNbu, uint liquidityBnbNbu) = swapRouter.addLiquidityBNB{value: amountBNB}(address(nbuToken), amountsBnbNbuSwap[1], 0, 0, address(this), block.timestamp);
      amountBNB -= amountBnbNbu;
      
      (, uint amountBnbGnbu, uint liquidityBnbGnbu) = swapRouter.addLiquidityBNB{value: amountBNB}(address(gnbuToken), amountsBnbGnbuSwap[1], 0, 0, address(this), block.timestamp);
      amountBNB -= amountBnbGnbu;
      
      uint256 noncesBnbNbu = lpStakingBnbNbu.stakeNonces(address(this));
      lpStakingBnbNbu.stake(liquidityBnbNbu);
      uint amountRewardEquivalentBnbNbu = lpStakingBnbNbu.getCurrentLPPrice() * liquidityBnbNbu / 1e18;
      _balancesRewardEquivalentBnbNbu[tokenCount] += amountRewardEquivalentBnbNbu;

      uint256 noncesBnbGnbu = lpStakingBnbGnbu.stakeNonces(address(this));
      lpStakingBnbGnbu.stake(liquidityBnbGnbu);
      uint amountRewardEquivalentBnbGnbu = lpStakingBnbGnbu.getCurrentLPPrice() * liquidityBnbGnbu / 1e18;
      _balancesRewardEquivalentBnbGnbu[tokenCount] += amountRewardEquivalentBnbGnbu;
      
      UserSupply storage userSupply = tikSupplies[tokenCount];
      userSupply.IsActive = true;
      userSupply.GnbuBnbLpAmount = liquidityBnbGnbu;
      userSupply.NbuBnbLpAmount = liquidityBnbNbu;
      userSupply.NbuBnbStakeNonce = noncesBnbNbu;
      userSupply.GnbuBnbStakeNonce = noncesBnbGnbu;
      userSupply.SupplyTime = block.timestamp;
      userSupply.TokenId = tokenCount;

      weightedStakeDate[tokenCount] = userSupply.SupplyTime;
      _userTokens[msg.sender].push(tokenCount); 
      _mint(msg.sender, tokenCount);

      return tokenCount;
    }
    
    function withdrawUserRewards(uint tokenId) external nonReentrant {
        require(_owners[tokenId] == msg.sender, "SmartLP: Not token owner");
        UserSupply memory userSupply = tikSupplies[tokenId];
        require(userSupply.IsActive, "SmartLP: Not active");
        uint nbuReward = getTotalAmountsOfRewards(tokenId);
        _withdrawUserRewards(tokenId, nbuReward);
    }
    
    function burnSmartLP(uint tokenId) external nonReentrant {
        require(_owners[tokenId] == msg.sender, "SmartLP: Not token owner");
        UserSupply storage userSupply = tikSupplies[tokenId];
        require(block.timestamp > userSupply.SupplyTime + lockTime, "SmartLP: Token is locked");
        require(userSupply.IsActive, "SmartLP: Token not active");
        uint nbuReward = getTotalAmountsOfRewards(tokenId);
        
        if(nbuReward > 0) {
            _withdrawUserRewards(tokenId, nbuReward);
        }

        lpStakingBnbNbu.withdraw(userSupply.NbuBnbStakeNonce);
        swapRouter.removeLiquidityBNB(address(nbuToken), userSupply.NbuBnbLpAmount, 0, 0,  msg.sender, block.timestamp);

        lpStakingBnbGnbu.withdraw(userSupply.GnbuBnbStakeNonce);
        swapRouter.removeLiquidityBNB(address(gnbuToken), userSupply.GnbuBnbLpAmount, 0, 0, msg.sender, block.timestamp);
        
        transferFrom(msg.sender, address(0x1), tokenId);
        userSupply.IsActive = false;
        
        emit BurnSmartLP(tokenId);      
    }

    function getTokenRewardsAmounts(uint tokenId) public view returns (uint lpBnbNbuUserRewards, uint lpBnbGnbuUserRewards) {
        UserSupply memory userSupply = tikSupplies[tokenId];
        require(userSupply.IsActive, "SmartLP: Not active");
        
        lpBnbNbuUserRewards = (_balancesRewardEquivalentBnbNbu[tokenId] * ((block.timestamp - weightedStakeDate[tokenId]) * 100)) / (100 * rewardDuration);
        lpBnbGnbuUserRewards = (_balancesRewardEquivalentBnbGnbu[tokenId] * ((block.timestamp - weightedStakeDate[tokenId]) * 100)) / (100 * rewardDuration);
    }
    
    function getTotalAmountsOfRewards(uint tokenId) public view returns (uint nbuReward) {
        (uint lpBnbNbuUserRewards, uint lpBnbGnbuUserRewards) = getTokenRewardsAmounts(tokenId);
        nbuReward = lpBnbNbuUserRewards + lpBnbGnbuUserRewards;
    }
    
    function getUserTokens(address user) public view returns (uint[] memory) {
        return _userTokens[user];
    }

    function _withdrawUserRewards(uint tokenId, uint totalNbuReward) private {
        require(totalNbuReward > 0, "SmartLP: Claim not enough");
        address tokenOwner = _owners[tokenId];
        if (nbuToken.balanceOf(address(this)) < totalNbuReward) {
            lpStakingBnbNbu.getReward();
            if (nbuToken.balanceOf(address(this)) < totalNbuReward) {
                lpStakingBnbGnbu.getReward();
            }
            emit BalanceRewardsNotEnough(tokenOwner, tokenId, totalNbuReward);
        }

        TransferHelper.safeTransfer(address(nbuToken), tokenOwner, totalNbuReward);
        weightedStakeDate[tokenId] = block.timestamp;

        emit WithdrawRewards(tokenOwner, tokenId, totalNbuReward);
    }



    // ========================== EIP 721 functions ==========================

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IBEP165) returns (bool) {
        return
            interfaceId == type(IBEP721).interfaceId ||
            interfaceId == type(IBEP721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = SmartLP.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }
    
    
    
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
    
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = SmartLP.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = SmartLP.ownerOf(tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: transfer to the zero address");
        require(SmartLP.ownerOf(tokenId) == from, "ERC721: transfer of token that is not owner");

        for (uint256 i; i < _userTokens[from].length; i++) {
            if(_userTokens[from][i] == tokenId) {
                _remove(i, from);
                break;
            }
        }
        // Clear approvals from the previous owner
        _approve(address(0), tokenId);
        _userTokens[to].push(tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _remove(uint index, address tokenOwner) internal virtual {
        _userTokens[tokenOwner][index] = _userTokens[tokenOwner][_userTokens[tokenOwner].length - 1];
        _userTokens[tokenOwner].pop();
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(SmartLP.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll( address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(address from, address to,uint256 tokenId, bytes memory _data) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    // ========================== Owner functions ==========================

    function rescue(address to, address tokenAddressUpgradeable, uint256 amount) external onlyOwner {
        require(to != address(0), "SmartLP: Cannot rescue to the zero address");
        require(amount > 0, "SmartLP: Cannot rescue 0");

        IERC20Upgradeable(tokenAddressUpgradeable).transfer(to, amount);
        emit RescueToken(to, address(tokenAddressUpgradeable), amount);
    }

    function rescue(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "SmartLP: Cannot rescue to the zero address");
        require(amount > 0, "SmartLP: Cannot rescue 0");

        to.transfer(amount);
        emit Rescue(to, amount);
    }

    function updateSwapRouter(address newSwapRouter) external onlyOwner {
        require(AddressUpgradeable.isContract(newSwapRouter), "SmartLP: Not a contract");
        swapRouter = IRouter(newSwapRouter);
        emit UpdateSwapRouter(newSwapRouter);
    }
    
    function updateLpStakingBnbNbu(address newLpStaking) external onlyOwner {
        require(AddressUpgradeable.isContract(newLpStaking), "SmartLP: Not a contract");
        lpStakingBnbNbu = ILpStaking(newLpStaking);
        emit UpdateLpStakingBnbNbu(newLpStaking);
    }
    
    function updateLpStakingBnbGnbu(address newLpStaking) external onlyOwner {
        require(AddressUpgradeable.isContract(newLpStaking), "SmartLP: Not a contract");
        lpStakingBnbGnbu = ILpStaking(newLpStaking);
        emit UpdateLpStakingBnbGnbu(newLpStaking);
    }
    
    function updateLendingContract(address newLendingContract) external onlyOwner {
        require(AddressUpgradeable.isContract(newLendingContract), "SmartLP: Not a contract");
        lendingContract = ILending(newLendingContract);
        emit UpdateLendingContract(newLendingContract);
    }

    function updateLockTime(uint256 _lockTime) external onlyOwner {
        lockTime = _lockTime;
    }
    
    function updateTokenAllowance(address token, address spender, int amount) external onlyOwner {
        require(AddressUpgradeable.isContract(token), "SmartLP: Not a contract");
        uint allowance;
        if (amount < 0) {
            allowance = type(uint256).max;
        } else {
            allowance = uint256(amount);
        }
        IERC20Upgradeable(token).approve(spender, allowance);
    }

    function updatePurchaseToken(address _purchaseToken) external onlyOwner {
        require(AddressUpgradeable.isContract(_purchaseToken), "SmartLP: Not a contract");
        purchaseToken = IERC20Upgradeable(_purchaseToken);
        IERC20Upgradeable(_purchaseToken).approve(address(pancakeRouter), type(uint256).max);
    }

    function updateMinPurchaseAmountToken (uint newAmount) external onlyOwner {
        require(newAmount > 0, "SmartLP: Amount must be greater than zero");
        minPurchaseAmountToken = newAmount;
        emit UpdateMinPurchaseAmountToken(newAmount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}