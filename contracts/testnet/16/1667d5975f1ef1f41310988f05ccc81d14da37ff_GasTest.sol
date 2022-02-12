/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.4;

//  Ref: https://github.com/projectchicago/gastoken/blob/master/contract/GST1.sol
contract GasTest
{
    //  Just for doing some "heavy" operations
    uint[]     _heavy;

    uint256 constant STORAGE_LOCATION_ARRAY = 0xDEADBEEF;    

    function clear() public
    {
        delete _heavy;

        uint256 storage_location_array = STORAGE_LOCATION_ARRAY;        
        assembly {
            sstore(storage_location_array, 0)
        }        

    }

    function store(uint slots) public
    {
        uint256 storage_location_array = STORAGE_LOCATION_ARRAY;        
        
        // Read supply
        uint256 supply;
        assembly {
            supply := sload(storage_location_array)
        }

        // Set memory locations in interval [l, r]
        uint256 l = storage_location_array + supply + 1;
        uint256 r = storage_location_array + supply + slots;
        assert(r >= l);

        for (uint256 i = l; i <= r; i++) {
            assembly {
                sstore(i, 1)
            }
        }

        // Write updated supply & balance
        assembly {
            sstore(storage_location_array, add(supply, slots))
        }        
    }

    function free(uint slots) public
    {
        uint256 storage_location_array = STORAGE_LOCATION_ARRAY;  // can't use constants inside assembly

        // Read supply
        uint256 supply;
        assembly {
            supply := sload(storage_location_array)
        }

        // Clear memory locations in interval [l, r]
        uint256 l = storage_location_array + supply - slots + 1;
        uint256 r = storage_location_array + supply;
        for (uint256 i = l; i <= r; i++) {
            assembly {
                sstore(i, 0)
            }
        }

        // Write updated supply
        assembly {
            sstore(storage_location_array, sub(supply, slots))
        }        
    }

    function test_savings(uint heavy_turns, int slots_to_free) public
    {
        uint gas_before = gasleft();

        for(uint I = 0; I < heavy_turns; ++I)
            _heavy.push(1);

        if(slots_to_free < 0)
        {
            //  Roughly counting
            slots_to_free = int((gasleft() - gas_before) / 15000);
        }

        free(uint(slots_to_free));
    }
}