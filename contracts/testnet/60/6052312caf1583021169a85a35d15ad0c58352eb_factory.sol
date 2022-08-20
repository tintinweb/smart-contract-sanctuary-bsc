// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "./StandardToken.sol";

contract factory {

    uint256 public token_counter = 0;
    uint256 [] token_count;

    struct TokenCreation {
        string name;
        string symbol;
        uint8 decimals;
        uint256 initialSupply;
        address owner_address;
        IERC20 token_address;
    }

    mapping(uint256 => TokenCreation) public token_creation;

    event ERC20TokenCreated(address tokenAddress);
    event NewToken(
        string name,
        string symbol,
        uint8 decimals,
        uint256 initialSupply,
        address owner_address
    );

    function deployNewERC20Token(
        string calldata name,
        string calldata symbol,
        uint8 decimals,
        uint256 initialSupply
    ) public returns (address) {

        ERC20Token t = new ERC20Token(
            name,
            symbol,
            decimals,
            initialSupply,
            msg.sender
        );

        TokenCreation storage t_creation = token_creation[token_counter];

        t_creation.name = name;
        t_creation.symbol = symbol;
        t_creation.decimals = decimals;
        t_creation.initialSupply = initialSupply;
        t_creation.owner_address = msg.sender;
        t_creation.token_address = t;

        token_count.push(token_counter);

        emit ERC20TokenCreated(address(t));

        emit NewToken(
            name,
            symbol,
            decimals,
            initialSupply,
            msg.sender
        );

        token_counter += 1;

        return address(t);
    }

    function getAllTokenCreation ()
            external
            view
            returns (
                TokenCreation[] memory
            )
        {
            uint256 length = token_count.length;

            TokenCreation[] memory prod_info = new TokenCreation[](length);

            for (uint256 i = 0; i < length; i++) {
                prod_info[i] = token_creation[i];
            }

            return (prod_info);
    }
}