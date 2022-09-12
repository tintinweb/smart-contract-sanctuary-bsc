// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "./GameToken.sol";


contract GameFactory {

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

        GameToken t = new GameToken(
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

    function removeToken(uint256 _token_id) external {
        for(uint256 i = _token_id; i < token_count.length - 1; i++){
            token_count[i] = token_count[i + 1];
        }
        token_count.pop();
    }


    function getTokenCreatedBySize (
        uint256 start,
        uint256 size
    )
        external
        view
        returns (
            uint256[] memory,
            TokenCreation[] memory,
            uint256
        )
    {
        uint256 length = size;

        if (length > token_count.length - start) {
            length = token_count.length - start;
        }

        uint256[] memory values = new uint256[](length);
        TokenCreation[] memory token_info = new TokenCreation[](length);

        for (uint256 i = 0; i < length; i++) {
            values[i] = token_count[start + i];
            token_info[i] = token_creation[values[i]];
        }

        return (values, token_info, start + length);
    }


}