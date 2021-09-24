<?php

// @TODO Use data/supported-extensions to exlcude incompatible incompatible extensions given a PHP version

$content = json_decode(file_get_contents(__DIR__ . '/data/pecl-extensions.json'), true);

$php_versions = [
	'8.0.1RC2',
	'8.0.10',
	'7.3.30',
	'7.4.23',
	'5.6.40'
];

function latest_version(string ...$versions): string {
	usort($versions, fn($a, $b) => version_compare($a, $b));

	return $versions[0];
}

function find_max(int $index, array $phpv): string {
	$default = '99.99.99';
	$current = $index+1;
	while(isset($phpv[$current])) {
		$php_max = $phpv[$current]['max'] ?? $default;
		$current++;
	}

	return $php_max ?? $default;
}

function find_min(int $index, array $phpv): string {
	$default = '0.0.0';
	$current = $index-1;
	while(isset($phpv[$current])) {
		$php_min = $phpv[$current]['min'] ?? $default;
		--$current;
	}

	return $php_min ?? $default;
}

foreach($php_versions as $php_version) {
	foreach($content as $extension) {
		$ext_name = strtolower($extension['name']);
		$ext_version = null;
		$phpv = $extension['phpv'] ?? [];
		foreach($phpv as $i => $ext) {
			$latestVersion = latest_version(...$ext['v']);
			$min = $ext['min'] ?? find_min($i, $phpv);
			$max = $ext['max'] ?? find_max($i, $phpv);
			if (version_compare($php_version, $min, '>=') && version_compare($php_version, $max, '<=')) {
				$ext_version = $latestVersion;
			}
		}
		if ($ext_version !== null) {
			echo 'php:',$php_version,':',$ext_name,':',$ext_version,PHP_EOL;
		}
	}
}
