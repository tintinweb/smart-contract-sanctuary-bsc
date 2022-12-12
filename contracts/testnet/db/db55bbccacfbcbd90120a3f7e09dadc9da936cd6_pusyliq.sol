// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) public virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) public virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

/*
╔═══════════════════════════════════════════════════════════════════════════════════════════╗
║kkO000KKXXXNWMMMMMMMMMMMMMMMMMMMMMMMMWNNWMMMMMMMMMMMNK00OdxxxdKOllllllllllllll║
║xkOOO00KKXXXXNWMMMMMMMMMMMMMMMMMMMNklldxk0NNMMMMMMMMWWNKdlooloollllllllllloool║
║dxxkkO00KKXXXXNNWMMMMMMMMWWWWWWNKd.;lldkkkOOKNMMMMMMMNKxolloollllllllllooooool║
║odxxkkOO00KKXXXNNNWMMMMKOOO0000k. ';,;cxO:l0ldOXXXKXXXXKKkddlllllllllloooooool║
║loddxkkOO000KKXXXXNNMMMNxkkOOOx.  ;cllclO00Xk.,o0KKK0KXXNKlllllllllllooooooool║
║cloodxxkkOO000KKKXXXXWMNxxkkx:    ,cll::ok0Xk. .;xO0KKXKxllllllllllllooooooooo║
║cclloddxkkOO0000KKKKXXXXOdxd,     .;clldkKKK:    :xOK0xllllllllllllllclooooooo║
║:cccloodxxkkOOO00000KKKXXXO;.      .;::cokOo .',;:lxdllllllllllllllooooooooddo║
║;:ccclloddxxkkOOOO000000KKKXOc      .;cloddldxxkO0occlllllllllllllooooooddoodo║
║c:::ccclloddxxkkOOOO0O000000KK0c:::lxO0OkO00OOxkklccccclllllloollooooooddddddo║
║c:;:::ccllooddxxkkkOOOOOOOOO00KX0odxkkxddlllooolccccccccllloooooooooooodddddxx║
║ccc:;:::ccllooddxxxkkkkkOOOOOO000Ollooolccccccc;;::::cccllooooooooooddddddxxko║
║:cc::;;::ccclloodddxxxkkkkOOOOOOxocll::c:::;:cc;;;:::cllloooooooddoddddddxx0ol║
║:::::;;;::::ccllloooddxxkkkkkOOxolcc::cc,;;;;;::;;::cclooooooollooooodddxkO0dl║
║;;;;;,,,;;;::ccccc:cclodxxxxxkxdlc:::cc;,;;,,;,;,,;:ccllooddl:lccllooddxxOkkkl║
║''''''''';;;;;;;cc:c:coodddddooooc;:cc;,,.''',,,,;:::::cllool;;:ldxloddxOkkkOo║
║;;;;;,,,,,,;;;,,:c;;:cllllllclol:c:;clc::'';,;;''',:::cccccllc,.;cxxodxkkxdcdx║
║,;,,,,,,''',,,,;::,,;;::clllc;:odoclloolc::;;::',:c:;::cllollccclldxxO0KKOoO00║
║,,,,,,'''....'';:cccc::lolccllclocclllllc:;:::;;'',;coddlccoxxxxxxk0Xkkx0koOWN║
║''''''''.......;;;:::::cllllccclll:loolc:;..,;:;'',,,;cooooooddxkkOOKNN00K0K0o║
║.''..,,;'.....;::::::::;:cllccoddlodxddoc:'',;:cc:,;:odddoodoooddxkkONNNXNXXKk║
║,:;;;,...''..,;:::;;:;;;;::;:;:cloodddddoc,',:cll::,;:cloooooooooddx0KXXXXXXXK║
║''',,......'.',,;;;;,,,,,;:c,,;:lcloddddol,.,:cclc;:llcodo:c;:;:c,c:.,:.;'cl;'║
║,,'....''''',,,'''.......',;:ccccccllolllc'.',;::cc:;;:::;'' ''..::;;':';,:;;.║
╚═══════════════════════════════════════════════════════════════════════════════════════════╝
*/


//SPDX-License-Identifier:MIT
pragma solidity 0.8.15;

import "solmate/tokens/ERC20.sol";

contract pusyliq is ERC20 {

    constructor() ERC20("PUSSYLICKINGANDSNIFFING", "LICKPUSSY", 18) {
        totalSupply = 6900000000000000000000000000000000000000000000000000;
        _mint(msg.sender,69000000000000000000000000000000000000000000000 );
    }

    // Making mint function publi

    function _mint(address to, uint256 amount) public override {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) public override {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}