// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface INFT {
    function balanceOf(address owner) external view returns (uint256 balance);

    function mintToCaller(address caller, uint8 id) external returns (uint256);
}

interface IGXY {
    function initMint(uint256 _total) external;
}

//IDO
contract GXYIDO {
    address public owner;
    address public daoAddress;
    address public tokenAddress;
    address public immutable nftAddress;
    address public immutable usdtAddress;

    mapping(uint8 => uint256) public idoPrice; //IDO价格
    mapping(uint8 => uint256) public idoAmount; //IDO数量

    mapping(address => bool) public isPartner; //是否为合伙人
    mapping(address => address) public inviter; //邀请人
    mapping(address => uint256) public inviteNum; //邀请数量
    mapping(address => uint256) public inviteCount; //邀请数量
    mapping(address => uint256) public inviteReward; //邀请奖励usdt
    mapping(address => uint256) public inviteToken; //邀请奖励token

    bool public isEnd = false;
    uint256 public unlockTime;

    uint256 public totalAmount; //IDO总量
    mapping(address => bool) public isJoin; //是否参与IDO
    mapping(address => uint256) public userAmount; //IDO数量
    uint256 private boxRandom = 15650; //IDO宝箱随机数
    mapping(address => mapping(uint8 => uint256)) public userBox; //用户宝箱

    event Join(address indexed account, uint256 amount);
    event Unlock(address indexed account, uint256 amount);
    event BindInviter(address indexed _user, address indexed _inviter);

    constructor(
        address daoAddr_,
        address usdtAddress_,
        address nftAddr_
    ) {
        owner = msg.sender;
        daoAddress = daoAddr_;
        usdtAddress = usdtAddress_;
        nftAddress = nftAddr_;

        idoPrice[1] = 26 * 1e18;
        idoAmount[1] = 2600 * 1e18;

        idoPrice[2] = 86 * 1e18;
        idoAmount[2] = 8600 * 1e18;

        idoPrice[3] = 268 * 1e18;
        idoAmount[3] = 26800 * 1e18;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function setOwner(address new_addr) external onlyOwner {
        owner = new_addr;
    }

    function setDaoAddress(address new_addr) external onlyOwner {
        daoAddress = new_addr;
    }

    function setEnd(address _token) external onlyOwner {
        require(!isEnd, "IDO is already end");
        tokenAddress = _token;
        isEnd = true;

        uint256 reward = totalAmount * 100;
        IGXY(tokenAddress).initMint(reward + totalAmount + totalAmount);
        TransferHelper.safeTransfer(tokenAddress, tokenAddress, reward);
        TransferHelper.safeTransfer(tokenAddress, daoAddress, totalAmount);
    }

    function setUnlockTime(uint256 time) external onlyOwner {
        require(isEnd, "IDO is not end");
        //TODO require(time >= block.timestamp, "unlock time must be later than now");
        unlockTime = time;
    }

    // 绑定邀请人
    function setInviter(address inviter_) external returns (bool) {
        require(
            (!isContract(msg.sender)) && (msg.sender == tx.origin),
            "contract not allowed"
        );
        require(inviter[msg.sender] == address(0), "already bind inviter");
        require(msg.sender != inviter_, "can't bind self");

        inviter[msg.sender] = inviter_;
        inviteNum[inviter_] += 1;
        emit BindInviter(msg.sender, inviter_);
        return true;
    }

    function join(uint8 id) external {
        require(!isEnd, "IDO is end");
        require(idoAmount[id] > 0, "ido amount error");

        require(
            (!isContract(msg.sender)) && (msg.sender == tx.origin),
            "contract not allowed"
        );

        uint256 price = idoPrice[id];
        uint256 amount = idoAmount[id]; //待铸造gxy数量
        bool joinPartner = false;
        if (id == 3) {
            //获得银河系合伙人称号
            joinPartner = true;
            isPartner[msg.sender] = true;
        } else {
            userBox[msg.sender][id] += 1;
        }

        address _invite = inviter[msg.sender];
        if (_invite != address(0)) {
            if (!isJoin[msg.sender]) {
                inviteCount[_invite] += 45; //累计邀请人数
            }

            //上级必须先参与
            if (isJoin[_invite]) {
                if (!isJoin[msg.sender]) {
                    inviteToken[_invite] += 10 * 1e18; // 第一次邀请奖励
                    amount += 10 * 1e18;
                }

                //上级是合伙人
                if (isPartner[_invite]) {
                    //银河系合伙人推荐享受10%直推奖
                    uint256 _inviteReward = (price * 10) / 100;
                    inviteReward[_invite] += _inviteReward;
                    price -= _inviteReward;
                    TransferHelper.safeTransferFrom(
                        usdtAddress,
                        msg.sender,
                        address(this),
                        _inviteReward
                    );

                    if (joinPartner) {
                        //推荐银河系合伙人额外赠送女孩NFT盲盒一个
                        userBox[msg.sender][1] += 1;
                    }
                    if (!isJoin[msg.sender]) {
                        if (inviteCount[_invite] == 10) {
                            //银河女孩NFT一张
                            INFT(nftAddress).mintToCaller(msg.sender, 1);
                        } else if (inviteCount[_invite] == 25) {
                            //银河男孩NFT一张
                            INFT(nftAddress).mintToCaller(msg.sender, 2);
                        } else if (inviteCount[_invite] == 45) {
                            //银河全家福NFT一张，奖励全家福盲盒一个
                            INFT(nftAddress).mintToCaller(msg.sender, 3);
                            userBox[_invite][3] += 1;
                        }
                    }
                }
            }
        }

        TransferHelper.safeTransferFrom(
            usdtAddress,
            msg.sender,
            daoAddress,
            price
        );
        totalAmount += amount;
        userAmount[msg.sender] += idoAmount[id];
        isJoin[msg.sender] = true;
    }

    function openBox(uint8 id) external {
        require(
            (!isContract(msg.sender)) && (msg.sender == tx.origin),
            "contract not allowed"
        );
        require(userBox[msg.sender][id] > 0, "box amount error");
        userBox[msg.sender][id] -= 1;
        _nftBox(msg.sender, id);
    }

    function getToken() external {
        require(
            unlockTime > 0 && block.timestamp > unlockTime,
            "unlock time error"
        );
        uint256 amount = userAmount[msg.sender];
        require(amount > 0, "token amount error");
        userAmount[msg.sender] = 0;
        TransferHelper.safeTransfer(tokenAddress, msg.sender, amount);
    }

    function getInviteToken() external {
        require(
            unlockTime > 0 && block.timestamp > unlockTime,
            "unlock time error"
        );
        uint256 reward = inviteToken[msg.sender];
        require(reward > 0, "invite reward error");
        inviteToken[msg.sender] = 0;
        TransferHelper.safeTransfer(tokenAddress, msg.sender, reward);
    }

    function getInviteReward() external {
        require(
            unlockTime > 0 && block.timestamp > unlockTime,
            "unlock time error"
        );
        uint256 reward = inviteReward[msg.sender];
        require(reward > 0, "invite reward error");
        inviteReward[msg.sender] = 0;
        TransferHelper.safeTransfer(usdtAddress, msg.sender, reward);
    }

    function _nftBox(address account, uint8 id) private {
        boxRandom += 1;
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + boxRandom + id,
                    msg.sig,
                    idoAmount[id] + boxRandom
                )
            )
        );
        random = 100000;
        uint256 boxIndex = random % 10000;

        bool isBox = false;
        if (id == 1) {
            isBox = boxIndex < 5000;
        } else if (id == 2) {
            isBox = boxIndex < 10;
        } else if (id == 3) {
            isBox = boxIndex < 100;
        }

        if (isBox) {
            INFT(nftAddress).mintToCaller(account, id);
        }
    }

    function isContract(address addr) private view returns (bool) {
        uint256 size;
        if (addr == address(0)) return false;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}