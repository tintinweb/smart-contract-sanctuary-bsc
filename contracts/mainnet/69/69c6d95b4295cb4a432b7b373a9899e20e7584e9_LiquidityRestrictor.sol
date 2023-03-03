/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
// File: contracts/Tools/Context.sol


pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// File: contracts/Tools/Ownable.sol


pragma solidity ^0.8.17;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() internal virtual onlyOwner {
        _transferOwnership(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// File: contracts/Interfaces/IPancakePair.sol


pragma solidity ^0.8.17;

interface IPancakePair {
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
// File: contracts/Tools/LiquidityRestrictor.sol


pragma solidity ^0.8.0;



contract LiquidityRestrictor is Ownable {
    struct Parameters {
        bool bypass;
        mapping(address => bool) isInitializer;
        mapping(address => uint256) startedAt;
        mapping(address => bool) isLocalAgent;
    }
    mapping(address => Parameters) public parameters;
    mapping(address => bool) public isTrustedAgent;

    event SetBypass(address indexed token, bool bypassed);
    event SetInitializer(address indexed token, address indexed who, bool isInitializer);
    event SetLocalAgent(address indexed token, address indexed who, bool isLocalAgent);
    event SetTrustedAgent(address indexed who, bool isTrustedAgent);
    event Started(address indexed token, address indexed pair, uint256 timestamp);

 
    function setParameters(
        address token,
        address[] memory initializers,
        address[] memory localAgents
    ) external onlyOwner {
        setInitializers(token, initializers, true);
        setLocalAgents(token, localAgents, true);
    }


    function setBypass(address token, bool bypass) external onlyOwner {
        parameters[token].bypass = bypass;
        emit SetBypass(token, bypass);
    }

    function setInitializers(
        address token,
        address[] memory who,
        bool isInitializer
    ) public onlyOwner {
        for (uint256 i = 0; i < who.length; i++) {
            parameters[token].isInitializer[who[i]] = isInitializer;
            emit SetInitializer(token, who[i], isInitializer);
        }
    }

    function setLocalAgents(
        address token,
        address[] memory who,
        bool isLocalAgent
    ) public onlyOwner {
        for (uint256 i = 0; i < who.length; i++) {
            parameters[token].isLocalAgent[who[i]] = isLocalAgent;
            emit SetLocalAgent(token, who[i], isLocalAgent);
        }
    }

    function setTrustedAgents(address[] memory who, bool isTrustedAgent_) external onlyOwner {
        for (uint256 i = 0; i < who.length; i++) {
            isTrustedAgent[who[i]] = isTrustedAgent_;
            emit SetTrustedAgent(who[i], isTrustedAgent_);
        }
    }

    function assureByAgent(
        address token,
        address from,
        address to
    ) external returns (bool allow, string memory message) {
        if (!(isTrustedAgent[msg.sender] || parameters[token].isLocalAgent[msg.sender]))
            return (false, 'LR: not agent');
        return _assureLiquidityRestrictions(token, from, to);
    }


    function assureLiquidityRestrictions(address from, address to)
        external
        returns (bool allow, string memory message)
    {
        return _assureLiquidityRestrictions(msg.sender, from, to);
    }

    function _assureLiquidityRestrictions(
        address token,
        address from,
        address to
    ) internal returns (bool allow, string memory message) {
        Parameters storage params = parameters[token];
        if (params.startedAt[to] > 0 || params.bypass || !checkPair(token, to)) return (true, '');
        if (!params.isInitializer[from]) return (false, 'LR: unauthorized');
        params.startedAt[to] = block.timestamp;
        emit Started(token, to, block.timestamp);
        return (true, 'start');
    }

    function checkPair(address token, address possiblyPair) public view returns (bool isPair) {
        try this._checkPair(token, possiblyPair) returns (bool value) {
            if (token == address(0)) return true;
            return value;
        } catch {
            return false;
        }
    }

    function _checkPair(address token, address possiblyPair) public view returns (bool isPair) {
        address token0 = IPancakePair(possiblyPair).token0();
        address token1 = IPancakePair(possiblyPair).token1();
        return token0 == token || token1 == token;
    }

    function seeRights(address token, address who)
        public
        view
        returns (
            bool isInitializer,
            bool isLocalAgent,
            bool isTrustedAgent_
        )
    {
        return (parameters[token].isInitializer[who], parameters[token].isLocalAgent[who], isTrustedAgent[who]);
    }

    function seeStart(address token, address pair) public view returns (uint256 startedAt) {
        return parameters[token].startedAt[pair];
    }
}