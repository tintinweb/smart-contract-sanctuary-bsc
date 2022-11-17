/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// File: contracts/utils/Owner.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
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
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value
        );
        require(token.approve(spender, newAllowance));
    }
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function getTokens(address owner) external view returns (uint256[] memory);

    function transfer(address to, uint256 tokenId) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract StakeERC721 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public token;
    address nullAddress = 0x0000000000000000000000000000000000000000;

    //Mapping of mouse to timestamp
    mapping(address => mapping(uint256 => uint256)) internal tokenIdToTimeStamp;

    //Mapping of mouse to staker
    mapping(address => mapping(uint256 => address)) internal tokenIdToStaker;

    //Mapping of staker to mice
    mapping(address => mapping(address => uint256[])) internal stakerToTokenIds;

    mapping(address => uint256) internal tokenEmissionsRate;

    event Stake(address indexed account, address tokenAddress, uint256 tokenId);
    event Unstake(address indexed account, address tokenAddress, uint256 tokenId);

    function settokenEmissionsRate(address tokenAddress, uint256 EMISSIONS_RATE_)
        public
        onlyOwner
    {
        tokenEmissionsRate[tokenAddress] = EMISSIONS_RATE_;
    }

    constructor() {
        _owner = msg.sender;

        token = address(2);
        tokenEmissionsRate[address(0xDEB6d862952aAcaFdEe13ffe54e925edAB4d0d0c)] = uint256(67e14).div(86400);
        tokenEmissionsRate[address(0xc2D18105B98931D91B7192bD107D71Ff1B0052B9)] = uint256(76e14).div(86400);
        tokenEmissionsRate[address(0x13D8fad787cc9316Becfcc61392BE51B2f982eba)] = uint256(1e16).div(86400);
        tokenEmissionsRate[address(0x13FD29dB966204F5B0DDD1D77F31F11F34BEb5c7)] = uint256(14e15).div(86400);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function changeToken(address newToken) public onlyOwner {
        token = newToken;
    }

    function getTokensStaked(address staker, address tokenAddress)
        public
        view
        returns (uint256[] memory)
    {
        return stakerToTokenIds[staker][tokenAddress];
    }

    function remove(address staker, address tokenAddress, uint256 index) internal {
        if (index >= stakerToTokenIds[staker][tokenAddress].length) return;

        for (uint256 i = index; i < stakerToTokenIds[staker][tokenAddress].length - 1; i++) {
            stakerToTokenIds[staker][tokenAddress][i] = stakerToTokenIds[staker][tokenAddress][i + 1];
        }
        stakerToTokenIds[staker][tokenAddress].pop();
    }

    function removeTokenIdFromStaker(address staker, address tokenAddress, uint256 tokenId) internal {
        for (uint256 i = 0; i < stakerToTokenIds[staker][tokenAddress].length; i++) {
            if (stakerToTokenIds[staker][tokenAddress][i] == tokenId) {
                //This is the tokenId to remove;
                remove(staker, tokenAddress, i);
            }
        }
    }

    function stakeByIds(address tokenAddress, uint256[] memory tokenIds) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                IERC721(tokenAddress).ownerOf(tokenIds[i]) == msg.sender &&
                    tokenIdToStaker[tokenAddress][tokenIds[i]] == nullAddress,
                "Token must be stakable by you!"
            );

            IERC721(tokenAddress).transferFrom(msg.sender, address(this), tokenIds[i]);

            stakerToTokenIds[msg.sender][tokenAddress].push(tokenIds[i]);

            tokenIdToTimeStamp[tokenAddress][tokenIds[i]] = block.timestamp;
            tokenIdToStaker[tokenAddress][tokenIds[i]] = msg.sender;

            emit Stake(msg.sender, tokenAddress, tokenIds[i]);
        }
    }

    function unstakeAll(address tokenAddress) public {
        require(
            stakerToTokenIds[msg.sender][tokenAddress].length > 0,
            "Must have at least one token staked!"
        );
        uint256 totalRewards = 0;

        for (uint256 i = stakerToTokenIds[msg.sender][tokenAddress].length; i > 0; i--) {
            uint256 tokenId = stakerToTokenIds[msg.sender][tokenAddress][i - 1];

            IERC721(tokenAddress).transfer(msg.sender, tokenId);

            totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenAddress][tokenId]) * tokenEmissionsRate[tokenAddress]);

            removeTokenIdFromStaker(msg.sender, tokenAddress, tokenId);

            tokenIdToStaker[tokenAddress][tokenId] = nullAddress;

            emit Unstake(msg.sender, tokenAddress, tokenId);
        }

        if (address(token) == address(2)) {
            (bool success, ) = msg.sender.call{value: totalRewards}(new bytes(0));
            require(success, "TransferHelper: BNB_TRANSFER_FAILED");
        } else {
            IERC20(token).safeTransfer(msg.sender, totalRewards);
        }
    }

    function unstakeByIds(address tokenAddress, uint256[] memory tokenIds) public {
        uint256 totalRewards = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokenIdToStaker[tokenAddress][tokenIds[i]] == msg.sender,
                "Message Sender was not original staker!"
            );

            IERC721(tokenAddress).transfer(msg.sender, tokenIds[i]);

            
            totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenAddress][tokenIds[i]]) * tokenEmissionsRate[tokenAddress]);

            removeTokenIdFromStaker(msg.sender, tokenAddress, tokenIds[i]);

            tokenIdToStaker[tokenAddress][tokenIds[i]] = nullAddress;

            emit Unstake(msg.sender, tokenAddress, tokenIds[i]);
        }

        if (address(token) == address(2)) {
            (bool success, ) = msg.sender.call{value: totalRewards}(new bytes(0));
            require(success, "TransferHelper: BNB_TRANSFER_FAILED");
        } else {
            IERC20(token).safeTransfer(msg.sender, totalRewards);
        }
    }

    function claimByTokenId(address tokenAddress, uint256 tokenId) public {
        require(
            tokenIdToStaker[tokenAddress][tokenId] == msg.sender,
            "Token is not claimable by you!"
        );

        uint256 totalRewards = ((block.timestamp -
            tokenIdToTimeStamp[tokenAddress][tokenId]) * tokenEmissionsRate[tokenAddress]);

        tokenIdToTimeStamp[tokenAddress][tokenId] = block.timestamp;

        if (address(token) == address(2)) {
            (bool success, ) = msg.sender.call{value: totalRewards}(new bytes(0));
            require(success, "TransferHelper: BNB_TRANSFER_FAILED");
        } else {
            IERC20(token).safeTransfer(msg.sender, totalRewards);
        }
    }

    function claimAll(address tokenAddress) public {
        uint256[] memory tokenIds = stakerToTokenIds[msg.sender][tokenAddress];
        uint256 totalRewards = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokenIdToStaker[tokenAddress][tokenIds[i]] == msg.sender,
                "Token is not claimable by you!"
            );

            totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenAddress][tokenIds[i]]) *
                    tokenEmissionsRate[tokenAddress]);

            tokenIdToTimeStamp[tokenAddress][tokenIds[i]] = block.timestamp;
        }

        if (address(token) == address(2)) {
            (bool success, ) = msg.sender.call{value: totalRewards}(new bytes(0));
            require(success, "TransferHelper: BNB_TRANSFER_FAILED");
        } else {
            IERC20(token).safeTransfer(msg.sender, totalRewards);
        }
    }

    function getAllRewards(address staker, address tokenAddress) public view returns (uint256) {
        uint256[] memory tokenIds = stakerToTokenIds[staker][tokenAddress];
        uint256 totalRewards = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {

            totalRewards =
                totalRewards +
                ((block.timestamp - tokenIdToTimeStamp[tokenAddress][tokenIds[i]]) *
                    tokenEmissionsRate[tokenAddress]);
        }

        return totalRewards;
    }

    function getRewardsByTokenId(address tokenAddress, uint256 tokenId)
        public
        view
        returns (uint256)
    {
        require(
            tokenIdToStaker[tokenAddress][tokenId] != nullAddress,
            "Token is not staked!"
        );

        uint256 secondsStaked = block.timestamp - tokenIdToTimeStamp[tokenAddress][tokenId];


        return secondsStaked * tokenEmissionsRate[tokenAddress];
    }

    function getStaker(address tokenAddress, uint256 tokenId) public view returns (address) {
        return tokenIdToStaker[tokenAddress][tokenId];
    }

    function clearPot(address _token, address _to, uint256 _amount) external onlyOwner {
        if (address(_token) == address(2)) {
            (bool success, ) = _to.call{value: _amount}(new bytes(0));
            require(success, "TransferHelper: BNB_TRANSFER_FAILED");
        } else {
            IERC20(_token).safeTransfer(_to, _amount);
        }
    }

    function getTokenEmissionsRate(address tokenAddress) public view returns (uint256) {
        return tokenEmissionsRate[tokenAddress];
    }
}