// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IERC1155.sol";
import "./IERC20.sol";
import "./Address.sol";
import "./Strings.sol";

contract LaunchpadStaking is Ownable {
    using SafeMath for uint256;
    using Address for address;
    using Strings for uint256;

    event CreatePool(string indexed pool_id);
    event UpdatePool(string indexed pool_id);
    event ActivePool(string indexed pool_id);
    event Staking(string indexed pool_id, address user);
    event Withdraw(string indexed pool_id, address user);

    struct PoolStaking {
        string launchpad_id;
        uint256 qty_nft;
        uint256 total_stacking;
        uint256 start_time;
        uint256 end_time;
        bool active;
    }
    // pool_id => PoolStaking
    mapping(string => PoolStaking) public poolStaking;

    struct UserStaking {
        uint256 tokenId;
        string launchpad_id;
        uint256 qty;
    }
    // user => pool_id => UserStaking
    mapping(address => mapping(string => UserStaking)) public userStaking;
    mapping(address => bool) public blackList;

    LaunchpadNFTERC1155Core private LaunchpadCore;
    IERC1155 private LaunchpadNFT;
    address bot = 0xCAF84d187C3DD9d8ee91aFef9C9af5194dd3916e;
    address supervisor = 0x317A449138Dd7D2FD2c11a66D2FCB2B315e4711D;

    constructor(
        address _LaunchpadNFT
    )  {
        LaunchpadNFT = IERC1155(_LaunchpadNFT);
        LaunchpadCore = LaunchpadNFTERC1155Core(_LaunchpadNFT);
    }

    modifier onlySupervisor() {
        require(_msgSender() == supervisor, "require safe supervisor Address.");
        _;
    }
    modifier onlyBot(){
        require(_msgSender() == bot, "require safe Bot Address.");
        _;
    }
    function changeBot(address _bot) public onlyOwner {
        bot = _bot;
    }
    function changeSupervisor(address _supervisor) public onlyOwner {
        supervisor = _supervisor;
    }
    function setBlackList(address[] memory _user, bool _block) onlySupervisor public {
        for (uint256 index; index < _user.length; index++) {
            blackList[_user[index]] = _block;
        }
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public pure virtual returns (bytes32) {
        return this.onERC1155Received.selector;
    }

    /**
      * @dev Withdraw bnb from this contract (Callable by owner only)
      */
    function SwapExactToken(
        address coinAddress,
        uint256 value,
        address payable to
    ) public onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }
    receive() external payable{}

    function createPool(
        string memory pool_id,
        string memory launchpad_id,
        uint256 qty,
        uint256 start_time,
        uint256 end_time
    ) public onlyBot {
        require(bytes(pool_id).length > 0, "pool id not found");
        require(qty > 0, "qty sell 0");
        require(poolStaking[pool_id].qty_nft == 0, "pool created");
        require(start_time < end_time, "the end time must be greater than the start time");
        poolStaking[pool_id].qty_nft = qty;
        poolStaking[pool_id].launchpad_id = launchpad_id;
        poolStaking[pool_id].start_time = start_time;
        poolStaking[pool_id].end_time = end_time;
        poolStaking[pool_id].active = true;
        emit CreatePool(pool_id);
    }

    function updatePool(
        string memory pool_id,
        uint256 qty,
        uint256 start_time,
        uint256 end_time
    ) public onlyBot {
        require(bytes(pool_id).length > 0, "pool id not found");
        require(poolStaking[pool_id].qty_nft > 0, "pool not found");
        if(qty > 0){
            poolStaking[pool_id].qty_nft = qty;
        }
        if(start_time > 0){
            if(end_time > 0) {
                require(start_time < end_time, "the end time must be greater than the start time");
            } else {
                require(start_time < poolStaking[pool_id].end_time, "the end time must be greater than the start time");
            }
            poolStaking[pool_id].start_time = start_time;
        }
        if(end_time > 0){
            require(end_time > poolStaking[pool_id].start_time, "the end time must be greater than the start time");
            poolStaking[pool_id].end_time = end_time;
        }
        emit UpdatePool(pool_id);
    }

    function activePool(string memory pool_id, bool active) public onlyBot {
        require(bytes(pool_id).length > 0, "pool id not found");
        poolStaking[pool_id].active = active;
        emit ActivePool(pool_id);
    }

    function stacking(string memory pool_id) public {
        require(bytes(pool_id).length > 0, "pool id not found");
        require(poolStaking[pool_id].qty_nft > 0, "pool not found");
        require(block.timestamp >= poolStaking[pool_id].start_time, "Time hasn't started yet");
        require(block.timestamp < poolStaking[pool_id].end_time, "Time ended");
        require(poolStaking[pool_id].active == true, "pool is closed");
        require(blackList[_msgSender()] == false, "wallet is locked");
        uint256 tokenId = LaunchpadCore.getLaunchpadToTokenId(poolStaking[pool_id].launchpad_id);
        require(tokenId > 0, "nft not found");
        uint256 qty = LaunchpadNFT.balanceOf(_msgSender(), tokenId);
        require(qty >= poolStaking[pool_id].qty_nft, 'Not enough nft to join the pool');
        require(userStaking[_msgSender()][pool_id].tokenId == 0, "already joined this pool");
        LaunchpadNFT.safeTransferFrom(_msgSender(), address(this), tokenId, qty, "0x0");
        userStaking[_msgSender()][pool_id].tokenId = tokenId;
        userStaking[_msgSender()][pool_id].launchpad_id = poolStaking[pool_id].launchpad_id;
        userStaking[_msgSender()][pool_id].qty = poolStaking[pool_id].qty_nft;
        poolStaking[pool_id].total_stacking += poolStaking[pool_id].qty_nft;
        emit Staking(pool_id, _msgSender());
    }

    function withdraw(string memory pool_id) public {
        require(bytes(pool_id).length > 0, "pool id not found");
        require(block.timestamp >= poolStaking[pool_id].end_time, "Time is not over yet");
        require(blackList[_msgSender()] == false, "wallet is locked");
        require(userStaking[_msgSender()][pool_id].tokenId > 0, "Haven't joined the pool yet");
        LaunchpadNFT.safeTransferFrom(address(this), _msgSender(), userStaking[_msgSender()][pool_id].tokenId, userStaking[_msgSender()][pool_id].qty, "0x0");
        poolStaking[pool_id].total_stacking -= userStaking[_msgSender()][pool_id].qty;
        delete userStaking[_msgSender()][pool_id];
        emit Withdraw(pool_id, _msgSender());
    }
}