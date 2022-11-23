// Lib/Prize.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Prize {
    // Rewards for every winner
    struct Universal {
        address token;
        uint256 amount;
    }
    // Rewards only available to the luckiest winners
    struct Surprise {
        bool is_revealed;
        address token;
        uint256 amount;
        address nft_token;
        uint256 nft_token_id;
        uint256 surprise_id;
    }

    // Public Functions
    function universal_token(Universal storage _universal) public view returns (address) {
        return _universal.token;
    }

    function universal_amount(Universal storage _universal) public view returns (uint256) {
        return _universal.amount;
    }

    function surprise_token(Surprise storage _surprise) public view returns (address) {
        return _surprise.token;
    }

    function surprise_amount(Surprise storage _surprise) public view returns (uint256) {
        return _surprise.amount;
    }

    function surprise_nft_token(Surprise storage _surprise) public view returns (address) {
        return _surprise.nft_token;
    }

    function surprise_nft_id(Surprise storage _surprise) public view returns (uint256) {
        return _surprise.nft_token_id;
    }

    function surprise_surprise_id(Surprise storage _surprise) public view returns (uint256) {
        return _surprise.surprise_id;
    }

    function surprise_is_revealed(Surprise storage _surprise) public view returns (bool) {
        return _surprise.is_revealed;
    }

    //
    function _setUniversal(
        Universal storage _universal,
        address token_,
        uint256 amount_
    ) internal {
        _universal.token = token_;
        _universal.amount = amount_;
    }

    function _setSurprise(
        Surprise storage _surprise,
        address token_,
        uint256 amount_,
        address nft_token_,
        uint256 nft_token_id_
    ) internal {
        _surprise.token = token_;
        _surprise.amount = amount_;
        _surprise.nft_token = nft_token_;
        _surprise.nft_token_id = nft_token_id_;
    }

    function _superLuckyMan(Surprise storage _surprise, uint256 surprise_id_) internal {
        _surprise.is_revealed = true;
        _surprise.surprise_id = surprise_id_;
    }
}