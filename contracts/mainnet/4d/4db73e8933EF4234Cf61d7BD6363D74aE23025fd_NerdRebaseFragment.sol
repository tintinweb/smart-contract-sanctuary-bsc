/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;



// File: NerdRebaseFragment.sol

contract NerdRebaseFragment {
    /// @notice This is so the function can be updated later, The params are all the data that needs to be passed from the og contract to the new one
    /// @param accounting all accounting uint data
    /// @param team all team uint data
    /// @param claims all claims data
    /// @param users current user and upline - this implementation does not use this value, but just in case, we're requesting it anyway
    /// @param totalRebases current rebase count
    function getNerdAdjustedRebase(
        uint256[9] calldata accounting,
        uint256[10] calldata team,
        uint256[5] calldata claims,
        address[2] calldata users,
        uint256 totalRebases
    )
        external
        pure
        returns (
            uint256 _totalRebase,
            uint256 _userRebase,
            uint256 _totalRebaseCount,
            int256 _percent
        )
    {
        uint256 _nfv = accounting[0] + team[5];
        if (_nfv == 0) _nfv = 1;
        // added rolls that offset compounding amounts in claims
        int256 playable = (int256)(_nfv + accounting[2]) -
            (int256)(claims[1] + claims[2]);
        _percent = (playable * 100_0000) / (int256)(_nfv);

        _totalRebaseCount = totalRebases; // GET LAST REBASE TIME
        uint256 rebase_Count = accounting[7] > _totalRebaseCount
            ? 0
            : _totalRebaseCount - accounting[7]; // Rebases pending
        // Each rebase increases the bag by 2% / 48
        _totalRebase = (accounting[3] + _nfv) * 2 * rebase_Count;
        _totalRebase = _totalRebase / 4800;
        _totalRebase += accounting[6];

        if (_percent <= -33_0000)
            return (_totalRebase, 0, _totalRebaseCount, _percent);

        uint256 maxRebase = (_nfv * uint256(_percent + 33_0000)) / 100_0000;
        // Cap rebase withdraw to what takes them to -33%
        if (_totalRebase > maxRebase) _totalRebase = maxRebase;
        // Well behaved user... full amount
        if (_percent > 0)
            return (_totalRebase, _totalRebase, _totalRebaseCount, _percent);
        // Poorly behaved user... no amount
        // in the negative, reduce rewards linearly
        _userRebase = ((uint256)(33_0000 + _percent) * _totalRebase) / 33_0000;
    }
}