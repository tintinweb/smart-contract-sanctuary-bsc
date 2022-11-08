// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./RabbitGame.sol";

contract RabbitGameFactory {
    address[] public games;

    function create(address token, uint256 timeDelta) public {
        require(token != address(0), "invalid token");
        RabbitGame game = new RabbitGame(msg.sender, token, timeDelta);
        game.increaseSalt(block.timestamp + games.length);
        games.push(address(game));
    }

    function getGamesLen() public view returns (uint256) {
        return games.length;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/IERC20.sol";

contract RabbitGame {
    mapping(address => uint256) public wins;
    address[] public winList;
    mapping(address => uint256) public loses;
    address[] public loseList;

    IERC20 public token;
    uint256 public round = 1;
    address public owner;
    uint256 public timeDelta;
    uint256 public time;

    constructor(
        address _owner,
        address _token,
        uint _timeDelta
    ) {
        token = IERC20(_token);
        owner = _owner;
        timeDelta = _timeDelta;
        time = block.timestamp;
    }

    event RabbitGameEvent(
        address indexed from,
        address indexed token,
        uint256 value,
        bool winSide
    );

    function play(uint256 amount, bool winSide) public {
        require(amount > 0, "require amount > 0");
        uint256 before = token.balanceOf(address(this));
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "transferFrom failed"
        );
        uint256 realAmount = token.balanceOf(address(this)) - before;
        require(realAmount > 0, "require realAmount > 0");

        increaseSalt(realAmount + (winSide ? amount + 666 : amount + 888));
        bool append = true;
        if (winSide) {
            for (uint256 i = 0; i < winList.length; i++) {
                if (winList[i] == msg.sender) {
                    append = false;
                    break;
                }
            }
            if (append) {
                winList.push(msg.sender);
            }
            wins[msg.sender] += realAmount;
        } else {
            for (uint256 i = 0; i < loseList.length; i++) {
                if (loseList[i] == msg.sender) {
                    append = false;
                    break;
                }
            }
            if (append) {
                loseList.push(msg.sender);
            }
            loses[msg.sender] += realAmount;
        }
        emit RabbitGameEvent(msg.sender, address(token), realAmount, winSide);
    }

    function reward() public {
        if (owner != address(0)) {
            require(msg.sender == owner, "require owner to execute");
        }
        if (timeDelta > 0) {
            require(block.timestamp > time + timeDelta, "no open");
            time = block.timestamp;
        }
        round++;
        uint256 winTotal = getWinTotal();
        uint256 loseTotal = getLoseTotal();
        uint256 total = winTotal + loseTotal;
        if (total == 0) {
            return;
        }
        uint256 win = (winTotal * 100) / total;

        if (getRandom() < win) {
            for (uint i = 0; i < winList.length; i++) {
                address addr = winList[i];
                uint256 amount = (total * wins[addr]) / winTotal;
                if (amount == 0) continue;
                token.transfer(addr, amount);
                wins[addr] = 0;
            }
            for (uint i = 0; i < loseList.length; i++) {
                if (loses[loseList[i]] > 0) {
                    loses[loseList[i]] = 0;
                }
            }
        } else {
            for (uint i = 0; i < loseList.length; i++) {
                address addr = loseList[i];
                uint256 amount = (total * loses[addr]) / loseTotal;
                if (amount == 0) continue;
                token.transfer(addr, amount);
                loses[addr] = 0;
            }
            for (uint i = 0; i < winList.length; i++) {
                if (wins[winList[i]] > 0) {
                    wins[winList[i]] = 0;
                }
            }
        }
    }

    uint256 private salt;

    function getRandom() public view returns (uint256) {
        uint256 random = uint256(
            keccak256(abi.encodePacked(blockhash(block.number - 1), salt))
        );
        return random % 100;
    }

    function increaseSalt(uint256 _salt) public {
        salt += _salt;
    }

    function getWinTotal() public view returns (uint256) {
        uint256 winTotal = 0;
        for (uint i = 0; i < winList.length; i++) {
            winTotal += wins[winList[i]];
        }
        return winTotal;
    }

    function getLoseTotal() public view returns (uint256) {
        uint256 loseTotal;
        for (uint i = 0; i < loseList.length; i++) {
            loseTotal += loses[loseList[i]];
        }
        return loseTotal;
    }

    function getWinListLen() public view returns (uint256) {
        return winList.length;
    }

    function getLoseListLen() public view returns (uint256) {
        return loseList.length;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}