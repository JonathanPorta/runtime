module "JEFRi Relationships"
asyncTest "has_a/has_a set", ->
	"Testing has_a relationships with back references."
	runtime = new JEFRi.Runtime "",
		debug:
			context:
				entities:
					Foo:
						key: "foo_id"
						properties:
							foo_id:
								type: "string"

							bar_id:
								type: "string"

						relationships:
							bar:
								type: "has_a"
								property: "bar_id"
								to:
									type: "Bar"
									property: "foo_id"

								back: "foo"

					Bar:
						key: "bar_id"
						properties:
							bar_id:
								type: "string"

							foo_id:
								type: "string"

						relationships:
							foo:
								type: "has_a"
								property: "foo_id"
								to:
									type: "Foo"
									property: "bar_id"

								back: "bar"
	runtime.ready.done ->
		ok runtime._instances.Foo, "Runtime instantiated."
		foo = runtime.build("Foo")
		fid = foo.id(true)
		bar = runtime.build("Bar")
		bid = bar.id(true)
		foo.bar = bar
		equal fid, foo.id(true), "Anchor kept id."
		equal bid, bar.id(true), "Related kept id."
		equal foo.bar_id, bar.foo_id, "Anchor rel prop is Related rel prop."
		ok foo._relationships.bar is bar, "Anchor points to correct related."
		ok bar._relationships.foo is foo, "Related points to correct anchor."
		start()


asyncTest "has_a/has_a (key relationship) set", ->
	"Testing specifically relationships through primary keys."
	runtime = new JEFRi.Runtime "",
		debug:
			context:
				entities:
					Foo:
						key: "foo_id"
						properties:
							foo_id:
								type: "string"

						relationships:
							bar:
								type: "has_a"
								property: "foo_id"
								to:
									type: "Bar"
									property: "foo_id"

								back: "foo"

					Bar:
						key: "foo_id"
						properties:
							foo_id:
								type: "string"

						relationships:
							foo:
								type: "has_a"
								property: "foo_id"
								to:
									type: "Foo"
									property: "foo_id"

								back: "bar"
	runtime.ready.done ->
		ok runtime._instances.Foo, "Runtime instantiated."
		foo = runtime.build("Foo")
		fid = foo.id(true)
		bar = runtime.build "Bar", { foo_id: foo.id() }
		bid = bar.id(true)
		foo.bar = bar
		equal fid, foo.id(true), "Anchor kept id."
		equal bid, bar.id(true), "Related kept id."
		equal foo.foo_id, bar.foo_id, "Anchor rel prop is Related rel prop."
		ok foo._relationships.bar is bar, "Anchor points to correct related."
		ok bar._relationships.foo is foo, "Related points to correct anchor."
		start()

asyncTest "has_many/has_a set", ->
	"Testing has_many to has_a relationships."
	runtime = new JEFRi.Runtime "",
		debug:
			context:
				entities:
					Foo:
						key: "foo_id"
						properties:
							foo_id:
								type: "string"
							bar_id:
								type: "string"
						relationships:
							bar:
								type: "has_a"
								property: "bar_id"
								to:
									type: "Bar"
									property: "bar_id"
								back: "foo"
					Bar:
						key: "bar_id"
						properties:
							bar_id:
								type: "string"

						relationships:
							foo:
								type: "has_many"
								property: "bar_id"
								to:
									type: "Foo"
									property: "foo_id"
								back: "bar"

	runtime.ready.done ->
		ok runtime._instances.Foo, "Runtime instantiated."
		foo_a = runtime.build("Foo")
		foo_b = runtime.build("Foo")
		fida = foo_a.id()
		fidb = foo_b.id()

		bar = runtime.build "Bar"
		bid = bar.id()

		foo_a.bar = bar
		foo_b.bar = bar

		equal foo_a.bar_id, bid, "Many side a got correct has_a id."
		equal foo_b.bar_id, bid, "Many side b got correct has_a id."
		equal bar.foo.length, 2, "bar has two foo"

		foo_a.bar = null
		strictEqual foo_a.bar_id, null, true, "foo_a bar_id unset."
		equal bar.foo.length, 1, "bar has one foo after removal."

		bar.foo.remove foo_b
		strictEqual foo_b.bar_id, null, "foo_b bar_id unset"
		equal bar.foo.length, 0, "bar has no foo"

		start()
