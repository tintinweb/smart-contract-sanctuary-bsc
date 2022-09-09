// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "./Ownable.sol";
import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface ITipDatabase {
    function registerTip(address from, address to, uint256 amount) external;
}

contract TipSwapper is Ownable {

    /**
        NBL Smart Contract
     */
    address public immutable NBL;

    /**
        Tip Database Instance
     */
    ITipDatabase public immutable Database;

    /**
        DEX Router To Market Buy NBL
     */
    IUniswapV2Router02 public router;

    /**
        Swap Path Between BNB -> NBL
     */
    address[] private path;

    /**
        Platform Fee
     */
    uint256 public fee = 500;
    uint256 public constant FEE_DENOM = 10**5;

    /**
        Fee Recipient
     */
    address public feeRecipient;

    /**
        Can Give Tips On Behalf Of Others
     */
    mapping ( address => bool ) public canTipOnBehalfOfOthers;

    /**
        Initialize Contract
     */
    constructor(
        address tipDatabase,
        address router_,
        address NBL_,
        address feeRecipient_
    ) {

        // NBL
        NBL = NBL_;

        // Set Fee Recipient
        feeRecipient = feeRecipient_;

        // Router
        router = IUniswapV2Router02(router_);

        // Database
        Database = ITipDatabase(tipDatabase);

        // Swap Path
        path = new address[](2);
        path[0] = router.WETH();
        path[1] = NBL;

        // set can tip on behalf of others
        canTipOnBehalfOfOthers[msg.sender] = true;

        // NBL Address:    0x11F331c62AB3cA958c5212d21f332a81c66F06e7
        // Router Address: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    }

    
    function setRouter(address newRouter) external onlyOwner {
        router = IUniswapV2Router02(newRouter);
    }

    function setFeeRecipient(address newRecipient) external onlyOwner {
        feeRecipient = newRecipient;
    }

    function setFee(uint256 newFee) external onlyOwner {
        require(
            newFee <= FEE_DENOM / 4,
            'Fee Too High'
        );
        fee = newFee;
    }

    function withdraw(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawETH() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s, 'ETH Send Failure');
    }

    function setCanTipOnBehalfOfOthers(address user, bool cantip) external onlyOwner {
        canTipOnBehalfOfOthers[user] = cantip;
    }

    receive() external payable {}

    function tipFrom(
        address from,
        address streamer
    ) external payable {
        require(
            canTipOnBehalfOfOthers[msg.sender],
            'Only Authorized Users Can Call'
        );

        // buy NBL
        uint256 received = _buy(msg.value);

        // Take NBL Tax
        uint256 toSend = _takeFeeNBL(received);

        // Register In DB
        Database.registerTip(from, streamer, toSend);

        // Send NBL To Streamer
        _send(streamer, toSend);
    }

    function tipFromWithNBL(
        address from,
        address streamer,
        uint256 amount
    ) external {
        require(
            canTipOnBehalfOfOthers[msg.sender],
            'Only Authorized Users Can Call'
        );

        // transfer in NBL
        uint received = _sendFrom(msg.sender, amount);

        // Take NBL Tax
        uint256 toSend = _takeFeeNBL(received);

        // Register In DB
        Database.registerTip(from, streamer, toSend);
        
        // Send NBL To Streamer
        _send(streamer, toSend);
    }

    function tip(
        address streamer
    ) external payable {
        
        // buy NBL
        uint256 received = _buy(msg.value);

        // Take NBL Tax
        uint256 toSend = _takeFeeNBL(received);

        // Register In DB
        Database.registerTip(msg.sender, streamer, toSend);

        // Send NBL To Streamer
        _send(streamer, toSend);
    }

    function tipWithNBL(
        address streamer,
        uint256 amount
    ) external {
        
        // transfer in NBL
        uint received = _sendFrom(msg.sender, amount);

        // Take NBL Tax
        uint256 toSend = _takeFeeNBL(received);

        // Register In DB
        Database.registerTip(msg.sender, streamer, toSend);
        
        // Send NBL To Streamer
        _send(streamer, toSend);
    }

    function tipWithOther(
        address token,
        address streamer,
        uint256 amount
    ) external {
        
        // transfer in Token
        uint received = _sendOtherFrom(token, msg.sender, amount);

        // swap token to NBL
        uint256 NBLReceived = _swapToNBL(token, received);

        // Take Fee In Token Tax
        uint256 toSend = _takeFeeNBL(NBLReceived);

        // Register In DB
        Database.registerTip(msg.sender, streamer, toSend);
        
        // Send NBL To Streamer
        _send(streamer, toSend);
    }


    function _takeFeeNBL(uint256 amount) internal returns (uint256) {
        uint _fee = ( amount * fee ) / FEE_DENOM;
        _send(feeRecipient, _fee);
        return amount - _fee;
    }

    function _send(address to, uint256 amount) internal {
        require(
            IERC20(NBL).transfer(to, amount),
            'ERR NBL Transfer'
        );
    }

    function _sendFrom(address from, uint256 amount) internal returns (uint256) {
        uint before = balanceOf(address(this));
        require(
            IERC20(NBL).allowance(from, address(this)) >= amount,
            'Insufficient Allowance'
        );
        require(
            IERC20(NBL).transferFrom(from, address(this), amount),
            'ERR NBL Transfer'
        );
        uint After = balanceOf(address(this));
        require(
            After > before,
            'Zero Received'
        );
        return After - before;
    }

    function _sendOtherFrom(address token, address from, uint256 amount) internal returns (uint256) {
        uint before = IERC20(token).balanceOf(address(this));
        require(
            IERC20(token).allowance(from, address(this)) >= amount,
            'Insufficient Allowance'
        );
        require(
            IERC20(token).transferFrom(from, address(this), amount),
            'ERR NBL Transfer'
        );
        uint After = IERC20(token).balanceOf(address(this));
        require(
            After > before,
            'Zero Received'
        );
        return After - before;
    }

    function _buy(uint amount) internal returns (uint256) {

        // NBL Balance Before
        uint256 before = balanceOf(address(this));

        // Make Swap
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            address(this),
            block.timestamp + 10
        );

        // NBL Balance After
        uint256 After = balanceOf(address(this));
        require(
            After > before,
            'Zero Received'
        );

        // Amount Received From Swap
        return After - before;
    }

    function _swapToNBL(address token, uint amount) internal returns (uint256) {

        // NBL Balance Before
        uint256 before = balanceOf(address(this));

        // Swap Path
        address[] memory sPath = new address[](3);
        sPath[0] = token;
        sPath[1] = router.WETH();
        sPath[2] = NBL;

        // Make Swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            sPath,
            address(this),
            block.timestamp + 10
        );

        // NBL Balance After
        uint256 After = balanceOf(address(this));
        require(
            After > before,
            'Zero Received'
        );

        // Amount Received From Swap
        return After - before;
    }

    function balanceOf(address user) public view returns (uint256) {
        return IERC20(NBL).balanceOf(user);
    } 
}