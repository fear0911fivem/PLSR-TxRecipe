function DefaultData()
    exports.oxmysql:execute('SELECT COUNT(*) as count FROM properties WHERE label = ?', { '1 Grove St' },
        function(results)
            if results and results[1] and results[1].count == 0 then
                local locationJson = json.encode({
                    front = {
                        z = 26.679443359375,
                        x = -33.92966842651367,
                        y = -1847.235107421875
                    },
                    backdoor = {
                        x = -42.875373840332,
                        y = -1859.2385253906,
                        z = 26.197219848633,
                        h = 139.80822753906
                    }
                })

                local upgradesJson = json.encode({
                    interior = 1
                })

                exports.oxmysql:execute(
                    'INSERT INTO properties (type, label, price, sold, owner, location, upgrades, locked, `keys`, data, foreclosed) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                    {
                        'house',
                        '1 Grove St',
                        100000,
                        0,
                        nil,
                        locationJson,
                        upgradesJson,
                        1,
                        '[]',
                        '[]',
                        0
                    },
                    function(result)
                        if result and result.insertId then
                            exports['pulsar-core']:LoggerTrace('Properties',
                                'Default property data inserted successfully')
                        else
                            exports['pulsar-core']:LoggerError('Properties', 'Failed to insert default property data')
                        end
                    end
                )
            else
                exports['pulsar-core']:LoggerTrace('Properties', 'Default property data already exists, skipping')
            end
        end)
end
