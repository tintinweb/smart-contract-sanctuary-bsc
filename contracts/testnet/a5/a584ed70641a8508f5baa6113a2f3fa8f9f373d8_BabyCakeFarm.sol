//SPDX-License-Identifier: UNLICENSED
pragma solidity >0.6.0;
pragma experimental ABIEncoderV2;

import "./OwnableUpgradeable.sol";
import "./PausableUpgradeable.sol";
import "./ReentrancyGuardUpgradeable.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./Math.sol";
import "./EnumerableSet.sol";

import "./IUniswapV2Router02.sol";

contract BabyCakeFarm is ReentrancyGuardUpgradeable, OwnableUpgradeable , PausableUpgradeable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    IERC20 public constant BABYCAKE = IERC20(0xdB8D30b74bf098aF214e862C90E647bbB1fcC58c);
    IERC20 public constant CAKE = IERC20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    IUniswapV2Router02 public uniswapV2Router;

    uint public totalShares;
    uint public totalSupply;
    mapping (address => uint) private _shares;
    mapping (address => uint) private _principal;
    mapping (address => uint) private _depositedAt;

    EnumerableSet.AddressSet users;
    
    address public feeRecipient;
    address payable public harvestor;

    uint public constant MAX_FEE = 10000;
    uint public performanceFee;
    uint public harvestFee;
    uint public minHarvestable;
    uint public minDepositAmount;

    modifier updateUserList {
        _;
        if (balanceOf(msg.sender) > 0 || claimable(msg.sender) > 0) _checkOrAddUser(msg.sender);
        else _removeUser(msg.sender);
    }

    function initialize() public initializer {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        performanceFee = 300;
        harvestFee = 30;
        minHarvestable = 10 ** 4;
        minDepositAmount = 0;
        
        feeRecipient = msg.sender;
        harvestor = msg.sender;
    }

    function balance() public view returns (uint) {
        return BABYCAKE.balanceOf(address(this));
    }

    function balanceOf(address account) public view returns(uint) {
        if (totalShares == 0) return 0;
        return balance().mul(sharesOf(account)).div(totalShares);
    }

    function sharesOf(address account) public view returns (uint) {
        return _shares[account];
    }

    function principalOf(address account) public view returns (uint) {
        return _principal[account];
    }

    function totalEarned() public view returns (uint) {
        uint totalBalance = balance();
        return totalBalance > totalSupply ? totalBalance.sub(totalSupply) : 0;
    }

    function getPricePerFullShare() public view returns (uint256) {
        if (totalShares == 0) return 1e18;
        return balance().mul(1e18).div(totalShares);
    }

    function deposit(uint _amount) public whenNotPaused nonReentrant updateUserList {
        require(msg.sender == tx.origin, 'no enduser');

        uint _pool = balance();
        uint _before = BABYCAKE.balanceOf(address(this));
        BABYCAKE.safeTransferFrom(msg.sender, address(this), _amount);
        uint _after = BABYCAKE.balanceOf(address(this));
        _amount = _after.sub(_before); // Additional check for deflationary tokens

        require(_amount >= minDepositAmount, 'too small amount');
        
        uint shares = 0;
        if (totalShares == 0) {
            shares = _amount;
        } else {
            shares = (totalShares.mul(_amount)).div(_pool);
        }

        totalShares += shares;
        totalSupply += _amount;
        _shares[msg.sender] += shares;       
        _principal[msg.sender] += _amount;
        _depositedAt[msg.sender] = block.timestamp;
    }

    function depositAll() external {
        deposit(BABYCAKE.balanceOf(msg.sender));
    }

    function withdraw(uint256 _amount) public updateUserList {
        uint amount = Math.min(_amount, _principal[msg.sender]);
        uint shares = Math.min(totalShares.mul(amount).div(balance()), _shares[msg.sender]);
        totalShares -= shares;
        totalSupply -= amount;
        _shares[msg.sender] -= shares;
        _principal[msg.sender] -= amount;
        _depositedAt[msg.sender] = block.timestamp;

        BABYCAKE.safeTransfer(msg.sender, amount);
    }

    function withdrawAll() external {
        withdraw(_principal[msg.sender]);
        claim();
    }

    function claimable(address account) public view returns (uint) {
        if (balanceOf(account) >= principalOf(account)) {
            return balanceOf(account).sub(principalOf(account));
        } else {
            return 0;
        }
    }

    function claim() public updateUserList {
        uint amount = claimable(msg.sender);
        if (amount == 0) return;
        uint shares = Math.min(totalShares.mul(amount).div(balance()), _shares[msg.sender]);
        totalShares -= shares;
        _shares[msg.sender] -=  shares;

        BABYCAKE.safeTransfer(msg.sender, amount);
    }

    function harvest() external {
        require(msg.sender == harvestor, '!harvestor');

        uint cakeAmount = CAKE.balanceOf(address(this));
        if (cakeAmount < minHarvestable) return; // CAKE amount is too small to compound
        
        if (performanceFee > 0) {
            uint feeAmount = cakeAmount.mul(performanceFee).div(MAX_FEE);
            CAKE.safeTransfer(feeRecipient, feeAmount);
        }

        if (harvestFee > 0) {
            uint feeAmount = cakeAmount.mul(harvestFee).div(MAX_FEE);
            address[] memory bnbPath = new address[](2);
            bnbPath[0] = address(CAKE);
            bnbPath[1] = uniswapV2Router.WETH();

            CAKE.safeApprove(address(uniswapV2Router), feeAmount);
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                feeAmount,
                0, // accept any amount of BNB
                bnbPath,
                harvestor, // The contract
                block.timestamp.add(180)
            );
        }

        address[] memory path = new address[](3);
        path[0] = address(CAKE);
        path[1] = uniswapV2Router.WETH();
        path[2] = address(BABYCAKE);

        cakeAmount = CAKE.balanceOf(address(this));
        CAKE.safeApprove(address(uniswapV2Router), cakeAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            cakeAmount,
            0, // accept any amount of BABYCAKE
            path,
            address(this), // Recipient
            block.timestamp.add(180)
        );
    }

    function _removeUser(address _user) internal {
        if (users.contains(_user) == true) {
            users.remove(_user);
        }
    }

    function _checkOrAddUser(address _user) internal {
        if (users.contains(_user) == false) {
            users.add(_user);
        }
    }

    function userCount() external view returns (uint) {
        return users.length();
    }

    function userList() external view onlyOwner returns (address[] memory) {
        address[] memory list = new address[](users.length());

        for (uint256 i = 0; i < users.length(); i++) {
            list[i] = users.at(i);
        }

        return list;
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        feeRecipient = _feeRecipient;
    }

    function setHarvestor(address payable _harvestor) external onlyOwner {
        require(msg.sender != address(0), 'zero address');

        harvestor = _harvestor;
    }

    function setPerformanceFee(uint _fee) external onlyOwner {
        require (_fee < MAX_FEE.div(2), '!fee');

        performanceFee = _fee;
    }

    function setHarvestFee(uint _fee) external onlyOwner {
        require (_fee < performanceFee, '!fee');

        harvestFee = _fee;
    }

    function setMinHarvestable(uint _amount) external onlyOwner {
        minHarvestable = _amount;
    }

    function setMinDepositAmount(uint _amount) external onlyOwner {
        minDepositAmount = _amount;
    }

    function setUniswapRouter(address _router) external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(_router);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function emergencyWithdraw(address _token, uint _amount) external onlyOwner {
        uint256 _bal = IERC20(_token).balanceOf(address(this));
        if (_bal < _amount) _amount = _bal;
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }
}